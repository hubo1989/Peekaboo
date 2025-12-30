//
//  AnnotationCanvas.swift
//  Peekaboo
//
//  Created on 2025-12-26.
//

import SwiftUI

/// Canvas view for drawing annotations on a screenshot
struct AnnotationCanvas: View {
    let image: NSImage
    @Bindable var manager: AnnotationManager
    let onComplete: (NSImage) -> Void
    let onCancel: () -> Void

    @State private var canvasSize: CGSize = .zero
    @State private var imageRect: CGRect = .zero

    /// Get the actual pixel dimensions of the image
    private var pixelSize: CGSize {
        if let rep = self.image.bestRepresentation(for: NSRect(origin: .zero, size: self.image.size), context: nil, hints: nil) {
            return CGSize(width: rep.pixelsWide, height: rep.pixelsHigh)
        }
        return self.image.size
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image - use interpolation for sharp rendering
                Image(nsImage: self.image)
                    .interpolation(.high)
                    .antialiased(true)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background(
                        GeometryReader { imageGeometry in
                            Color.clear.onAppear {
                                self.updateImageRect(
                                    containerSize: geometry.size,
                                    imageSize: self.image.size
                                )
                            }
                        }
                    )

                // Drawing canvas overlay
                Canvas { context, size in
                    // Draw all annotation elements
                    for element in self.manager.renderableElements {
                        element.draw(in: context)
                    }
                }
                .frame(width: self.imageRect.width, height: self.imageRect.height)
                .position(
                    x: self.imageRect.midX,
                    y: self.imageRect.midY
                )
                .contentShape(Rectangle())
                .gesture(self.drawingGesture)

                // Text input overlay
                if self.manager.isEditingText, let position = self.manager.textInputPosition {
                    self.textInputView(at: position)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                self.canvasSize = geometry.size
                self.updateImageRect(containerSize: geometry.size, imageSize: self.image.size)
            }
            .onChange(of: geometry.size) { _, newSize in
                self.canvasSize = newSize
                self.updateImageRect(containerSize: newSize, imageSize: self.image.size)
            }
        }
        .background(Color.black.opacity(0.8))
    }

    // MARK: - Drawing Gesture

    private var drawingGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let point = self.convertToImageCoordinates(value.location)

                if self.manager.currentDrawing == nil {
                    let shiftHeld = NSEvent.modifierFlags.contains(.shift)
                    self.manager.startDrawing(at: point, shiftHeld: shiftHeld)
                } else {
                    let shiftHeld = NSEvent.modifierFlags.contains(.shift)
                    self.manager.continueDrawing(to: point, shiftHeld: shiftHeld)
                }
            }
            .onEnded { _ in
                self.manager.finishDrawing()
            }
    }

    // MARK: - Text Input

    @ViewBuilder
    private func textInputView(at position: CGPoint) -> some View {
        let screenPosition = self.convertToScreenCoordinates(position)

        TextField("Enter text...", text: self.$manager.textInputContent)
            .textFieldStyle(.plain)
            .font(.system(size: self.manager.fontSize, weight: .medium))
            .foregroundColor(self.manager.strokeColor)
            .frame(minWidth: 100, maxWidth: 300)
            .padding(4)
            .background(Color.white.opacity(0.9))
            .cornerRadius(4)
            .position(screenPosition)
            .onSubmit {
                self.manager.completeTextInput()
            }
    }

    // MARK: - Coordinate Conversion

    private func convertToImageCoordinates(_ point: CGPoint) -> CGPoint {
        // Convert screen coordinates to image coordinates
        let x = point.x - self.imageRect.origin.x
        let y = point.y - self.imageRect.origin.y
        return CGPoint(x: x, y: y)
    }

    private func convertToScreenCoordinates(_ point: CGPoint) -> CGPoint {
        // Convert image coordinates to screen coordinates
        let x = point.x + self.imageRect.origin.x
        let y = point.y + self.imageRect.origin.y
        return CGPoint(x: x, y: y)
    }

    private func updateImageRect(containerSize: CGSize, imageSize: CGSize) {
        let aspectRatio = imageSize.width / imageSize.height
        var width = containerSize.width
        var height = width / aspectRatio

        if height > containerSize.height {
            height = containerSize.height
            width = height * aspectRatio
        }

        // Prevent upscaling small images to avoid blurriness
        if width > imageSize.width {
            width = imageSize.width
            height = imageSize.height
        }

        let x = (containerSize.width - width) / 2
        let y = (containerSize.height - height) / 2

        self.imageRect = CGRect(x: x, y: y, width: width, height: height)
    }
}

// MARK: - Render Final Image

extension AnnotationCanvas {
    /// Render the annotated image
    @MainActor
    static func renderAnnotatedImage(
        original: NSImage,
        annotations: [AnyAnnotation]
    ) -> NSImage {
        let size = original.size

        let newImage = NSImage(size: size)
        newImage.lockFocus()

        // Draw original image
        original.draw(
            in: CGRect(origin: .zero, size: size),
            from: .zero,
            operation: .copy,
            fraction: 1.0
        )

        // Draw annotations using Core Graphics
        guard let context = NSGraphicsContext.current?.cgContext else {
            newImage.unlockFocus()
            return newImage
        }

        // Flip coordinate system for proper rendering
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)

        // Create a SwiftUI GraphicsContext wrapper isn't directly possible,
        // so we'll render each element using Core Graphics directly
        for annotation in annotations {
            Self.renderAnnotation(annotation, in: context, size: size)
        }

        newImage.unlockFocus()
        return newImage
    }

    private static func renderAnnotation(
        _ annotation: AnyAnnotation,
        in context: CGContext,
        size: CGSize
    ) {
        // This is a simplified rendering approach
        // For full fidelity, we'd need to implement CG-based rendering for each type
        // For now, we use the bounds and basic drawing

        let bounds = annotation.bounds

        context.saveGState()

        // Draw a placeholder for the annotation
        context.setStrokeColor(NSColor.red.cgColor)
        context.setLineWidth(2)
        context.stroke(bounds)

        context.restoreGState()
    }
}

#Preview {
    let testImage = NSImage(size: CGSize(width: 800, height: 600))
    testImage.lockFocus()
    NSColor.lightGray.setFill()
    NSBezierPath(rect: CGRect(origin: .zero, size: testImage.size)).fill()
    testImage.unlockFocus()

    return AnnotationCanvas(
        image: testImage,
        manager: AnnotationManager(),
        onComplete: { _ in },
        onCancel: { }
    )
    .frame(width: 800, height: 600)
}
