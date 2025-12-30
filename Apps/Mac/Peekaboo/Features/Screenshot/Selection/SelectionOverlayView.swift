//
//  SelectionOverlayView.swift
//  Peekaboo
//
//  Created on 2025-12-26.
//

import SwiftUI

/// The SwiftUI view for the selection overlay
struct SelectionOverlayView: View {
    weak var coordinator: ScreenshotCoordinator?
    let screenFrame: CGRect
    let mode: SelectionMode
    var backgroundImage: NSImage?

    @State private var isDragging = false
    @State private var startPoint: CGPoint = .zero
    @State private var currentPoint: CGPoint = .zero
    @State private var mouseLocation: CGPoint = .zero
    @State private var bitmapRep: NSBitmapImageRep?

    private var selectionRect: CGRect {
        guard self.isDragging else { return .zero }

        let minX = min(self.startPoint.x, self.currentPoint.x)
        let minY = min(self.startPoint.y, self.currentPoint.y)
        let maxX = max(self.startPoint.x, self.currentPoint.x)
        let maxY = max(self.startPoint.y, self.currentPoint.y)

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Semi-transparent overlay
                Color.black.opacity(0.3)

                // Clear out the selected region
                if self.isDragging {
                    self.selectionOverlay(in: geometry)
                }

                // Crosshair cursor indicator
                if !self.isDragging {
                    self.crosshairView
                }

                // Magnifier view (when not dragging)
                if !self.isDragging {
                    self.magnifierView
                        .position(self.magnifierPosition)
                }

                // Dimension label
                if self.isDragging {
                    self.dimensionLabel
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            // Use high priority gesture to ensure drag takes precedence over hover
            .highPriorityGesture(self.dragGesture)
            .onContinuousHover { phase in
                // Only track hover when not dragging to avoid conflicts
                guard !self.isDragging else { return }
                switch phase {
                case .active(let location):
                    self.mouseLocation = location
                case .ended:
                    break
                }
            }
            .onAppear {
                if let image = self.backgroundImage {
                    // Create bitmap representation for color picking
                    // We use the CGImage directly to avoid TIFF conversion overhead if possible
                    if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                        self.bitmapRep = NSBitmapImageRep(cgImage: cgImage)
                    } else if let tiff = image.tiffRepresentation {
                        self.bitmapRep = NSBitmapImageRep(data: tiff)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Subviews

    @ViewBuilder
    private func selectionOverlay(in geometry: GeometryProxy) -> some View {
        // Create a mask that shows the selection area clearly
        ZStack {
            // Dark overlay with cutout
            Rectangle()
                .fill(Color.black.opacity(0.5))
                .mask(
                    Rectangle()
                        .fill(Color.white)
                        .overlay(
                            Rectangle()
                                .fill(Color.black)
                                .frame(
                                    width: self.selectionRect.width,
                                    height: self.selectionRect.height
                                )
                                .position(
                                    x: self.selectionRect.midX,
                                    y: self.selectionRect.midY
                                )
                                .blendMode(.destinationOut)
                        )
                        .compositingGroup()
                )

            // Selection border
            Rectangle()
                .stroke(Color.white, lineWidth: 2)
                .frame(
                    width: self.selectionRect.width,
                    height: self.selectionRect.height
                )
                .position(
                    x: self.selectionRect.midX,
                    y: self.selectionRect.midY
                )

            // Corner handles
            self.cornerHandles
        }
    }

    private var crosshairView: some View {
        ZStack {
            // Horizontal line
            Rectangle()
                .fill(Color.white)
                .frame(width: 21, height: 1)
                .position(self.mouseLocation)

            // Vertical line
            Rectangle()
                .fill(Color.white)
                .frame(width: 1, height: 21)
                .position(self.mouseLocation)
        }
    }

    private var magnifierView: some View {
        VStack(spacing: 4) {
            // Magnifier circle (placeholder - actual implementation would show zoomed pixels)
            Circle()
                .stroke(Color.white, lineWidth: 2)
                .background(Circle().fill(Color.black.opacity(0.8)))
                .frame(width: 100, height: 100)
                .overlay(
                    VStack {
                        Text("🔍")
                            .font(.system(size: 24))
                        Text("10x")
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                )

            // Color value display
            if let color = self.pixelColor {
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(nsColor: color))
                        .frame(width: 16, height: 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )

                    Text(self.hexString(for: color))
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.8))
                .cornerRadius(4)
            }
        }
    }

    private var pixelColor: NSColor? {
        guard let bitmap = self.bitmapRep else { return nil }

        // Convert screen point to image coordinates
        // Mouse location is in view coordinates (top-left origin)
        // Image coordinates depend on the bitmap, usually top-left for CGImage-based reps?
        // Actually NSBitmapImageRep usually follows the image data.
        // But we need to account for backing scale factor if the image is retina.

        // Let's assume the image size matches the screenFrame size (in points)
        // But the bitmap has actual pixels.

        let scaleX = CGFloat(bitmap.pixelsWide) / self.screenFrame.width
        let scaleY = CGFloat(bitmap.pixelsHigh) / self.screenFrame.height

        let x = Int(self.mouseLocation.x * scaleX)
        // NSImage/Bitmap usually uses top-left origin for data if created from CGImage?
        // No, Quartz/CoreGraphics is usually bottom-left, but image data in memory is usually top-left row-major.
        // NSBitmapImageRep colorAt(x, y) uses standard coordinate system (0,0 is usually top-left for data-based, but bottom-left for drawing).
        // Let's try top-down first since screen coordinates are top-down.
        let y = Int(self.mouseLocation.y * scaleY)

        guard x >= 0, x < bitmap.pixelsWide,
              y >= 0, y < bitmap.pixelsHigh else {
            return nil
        }

        return bitmap.colorAt(x: x, y: y)
    }

    private func hexString(for color: NSColor) -> String {
        guard let rgbColor = color.usingColorSpace(.sRGB) else { return "#000000" }
        let r = Int(rgbColor.redComponent * 255)
        let g = Int(rgbColor.greenComponent * 255)
        let b = Int(rgbColor.blueComponent * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    private var magnifierPosition: CGPoint {
        // Position magnifier to avoid going off screen
        let offsetX: CGFloat = 120
        let offsetY: CGFloat = 120

        var x = self.mouseLocation.x + offsetX
        var y = self.mouseLocation.y + offsetY

        // Adjust if too close to edges
        if x + 60 > self.screenFrame.width {
            x = self.mouseLocation.x - offsetX
        }
        if y + 80 > self.screenFrame.height {
            y = self.mouseLocation.y - offsetY
        }

        return CGPoint(x: x, y: y)
    }

    private var dimensionLabel: some View {
        let width = Int(self.selectionRect.width)
        let height = Int(self.selectionRect.height)

        return Text("\(width) × \(height)")
            .font(.system(size: 12, weight: .medium, design: .monospaced))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.8))
            .cornerRadius(4)
            .position(
                x: self.selectionRect.midX,
                y: self.selectionRect.maxY + 20
            )
    }

    private var cornerHandles: some View {
        let handleSize: CGFloat = 8
        let rect = self.selectionRect

        return ZStack {
            // Top-left
            Circle()
                .fill(Color.white)
                .frame(width: handleSize, height: handleSize)
                .position(x: rect.minX, y: rect.minY)

            // Top-right
            Circle()
                .fill(Color.white)
                .frame(width: handleSize, height: handleSize)
                .position(x: rect.maxX, y: rect.minY)

            // Bottom-left
            Circle()
                .fill(Color.white)
                .frame(width: handleSize, height: handleSize)
                .position(x: rect.minX, y: rect.maxY)

            // Bottom-right
            Circle()
                .fill(Color.white)
                .frame(width: handleSize, height: handleSize)
                .position(x: rect.maxX, y: rect.maxY)
        }
    }

    // MARK: - Gesture

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                if !self.isDragging {
                    self.startPoint = value.startLocation
                    self.isDragging = true
                }
                self.currentPoint = value.location
            }
            .onEnded { _ in
                self.completeSelection()
            }
    }

    private func completeSelection() {
        guard self.selectionRect.width > 5, self.selectionRect.height > 5 else {
            // Selection too small, cancel
            self.isDragging = false
            return
        }

        // Convert from view coordinates to screen coordinates
        let screenRect = CGRect(
            x: self.screenFrame.origin.x + self.selectionRect.origin.x,
            y: self.screenFrame.origin.y + (self.screenFrame.height - self.selectionRect.maxY),
            width: self.selectionRect.width,
            height: self.selectionRect.height
        )

        self.coordinator?.completeSelection(region: screenRect)
        self.isDragging = false
    }
}

#Preview {
    SelectionOverlayView(
        coordinator: nil,
        screenFrame: CGRect(x: 0, y: 0, width: 1920, height: 1080),
        mode: .area,
        backgroundImage: nil
    )
    .frame(width: 800, height: 600)
    .background(Color.gray)
}
