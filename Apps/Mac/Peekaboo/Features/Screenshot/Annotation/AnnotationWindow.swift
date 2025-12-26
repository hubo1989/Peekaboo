//
//  AnnotationWindow.swift
//  Peekaboo
//
//  Created on 2025-12-26.
//

import AppKit
import os.log
import SwiftUI
import UniformTypeIdentifiers

/// Window controller for the annotation interface
@MainActor
final class AnnotationWindowController {
    private let logger = Logger(subsystem: "boo.peekaboo.app", category: "AnnotationWindow")

    private var window: NSWindow?
    private weak var coordinator: ScreenshotCoordinator?
    private let image: NSImage
    private let annotationManager = AnnotationManager()

    init(image: NSImage, coordinator: ScreenshotCoordinator) {
        self.image = image
        self.coordinator = coordinator
    }

    /// Show the annotation window
    func show() {
        self.logger.info("Showing annotation window")

        // Create the content view
        let contentView = AnnotationWindowView(
            image: self.image,
            manager: self.annotationManager,
            onCopy: { [weak self] in self?.handleCopy() },
            onSave: { [weak self] in self?.handleSave() },
            onPin: { [weak self] in self?.handlePin() },
            onSendToAI: { [weak self] in self?.handleSendToAI() },
            onCancel: { [weak self] in self?.handleCancel() }
        )

        // Calculate window size based on image
        let screenFrame = NSScreen.main?.visibleFrame ?? CGRect(x: 0, y: 0, width: 1200, height: 800)
        let maxWidth = screenFrame.width * 0.9
        let maxHeight = screenFrame.height * 0.9

        var windowSize = self.image.size
        let aspectRatio = windowSize.width / windowSize.height

        if windowSize.width > maxWidth {
            windowSize.width = maxWidth
            windowSize.height = windowSize.width / aspectRatio
        }
        if windowSize.height > maxHeight {
            windowSize.height = maxHeight
            windowSize.width = windowSize.height * aspectRatio
        }

        // Add space for toolbar
        windowSize.height += 60

        // Create window
        let window = NSWindow(
            contentRect: CGRect(origin: .zero, size: windowSize),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = false
        window.backgroundColor = NSColor.black.withAlphaComponent(0.9)
        window.level = .floating
        window.center()

        window.contentView = NSHostingView(rootView: contentView)

        // Set up keyboard shortcuts
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyDown(event) ?? event
        }

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        self.window = window
    }

    /// Dismiss the annotation window
    func dismiss() {
        self.logger.info("Dismissing annotation window")
        self.window?.orderOut(nil)
        self.window = nil
    }

    // MARK: - Action Handlers

    private func handleCopy() {
        let finalImage = self.renderFinalImage()
        self.copyImageToClipboard(finalImage)
        self.dismiss()
        self.coordinator?.completeCapture()
    }

    private func handleSave() {
        let finalImage = self.renderFinalImage()
        self.saveImageToFile(finalImage)
    }

    private func handlePin() {
        let finalImage = self.renderFinalImage()
        self.dismiss()
        self.coordinator?.capturedImage = finalImage
        self.coordinator?.pinToDesktop()
    }

    private func handleSendToAI() {
        let finalImage = self.renderFinalImage()
        self.dismiss()
        self.coordinator?.capturedImage = finalImage
        self.coordinator?.sendToAI()
    }

    private func handleCancel() {
        self.dismiss()
        self.coordinator?.cancelCapture()
    }

    // MARK: - Keyboard Handling

    private func handleKeyDown(_ event: NSEvent) -> NSEvent? {
        // ESC to cancel
        if event.keyCode == 53 {
            self.handleCancel()
            return nil
        }

        // Cmd+Z for undo
        if event.modifierFlags.contains(.command), event.charactersIgnoringModifiers == "z" {
            if event.modifierFlags.contains(.shift) {
                self.annotationManager.redo()
            } else {
                self.annotationManager.undo()
            }
            return nil
        }

        // Cmd+C for copy
        if event.modifierFlags.contains(.command), event.charactersIgnoringModifiers == "c" {
            self.handleCopy()
            return nil
        }

        // Cmd+S for save
        if event.modifierFlags.contains(.command), event.charactersIgnoringModifiers == "s" {
            self.handleSave()
            return nil
        }

        return event
    }

    // MARK: - Image Operations

    private func renderFinalImage() -> NSImage {
        // Create a new image with annotations
        let size = self.image.size
        let newImage = NSImage(size: size)

        newImage.lockFocus()

        // Draw original image
        self.image.draw(
            in: CGRect(origin: .zero, size: size),
            from: .zero,
            operation: .copy,
            fraction: 1.0
        )

        // Draw annotations
        if let context = NSGraphicsContext.current?.cgContext {
            // Flip for proper coordinate system
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1, y: -1)

            // Draw each annotation
            for element in self.annotationManager.elements {
                self.drawAnnotation(element, in: context)
            }
        }

        newImage.unlockFocus()
        return newImage
    }

    private func drawAnnotation(_ annotation: AnyAnnotation, in context: CGContext) {
        // For a proper implementation, we'd need to cast back to specific types
        // This is a simplified version that draws basic shapes
        let bounds = annotation.bounds

        context.saveGState()
        context.setStrokeColor(NSColor.red.cgColor)
        context.setLineWidth(3)
        context.stroke(bounds)
        context.restoreGState()
    }

    private func copyImageToClipboard(_ image: NSImage) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        if let tiffData = image.tiffRepresentation {
            pasteboard.setData(tiffData, forType: .tiff)
            self.logger.info("Annotated image copied to clipboard")
        }
    }

    private func saveImageToFile(_ image: NSImage) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png, .jpeg]
        savePanel.nameFieldStringValue = "Screenshot-\(Self.timestampString())"

        savePanel.begin { [weak self] response in
            guard response == .OK, let url = savePanel.url else { return }

            guard let tiffData = image.tiffRepresentation,
                  let bitmapRep = NSBitmapImageRep(data: tiffData) else {
                return
            }

            let isPNG = url.pathExtension.lowercased() == "png"
            let fileType: NSBitmapImageRep.FileType = isPNG ? .png : .jpeg

            guard let imageData = bitmapRep.representation(using: fileType, properties: [:]) else {
                return
            }

            do {
                try imageData.write(to: url)
                self?.logger.info("Image saved to \(url.path)")
                self?.dismiss()
                self?.coordinator?.completeCapture()
            } catch {
                self?.logger.error("Failed to save image: \(error.localizedDescription)")
            }
        }
    }

    private static func timestampString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter.string(from: Date())
    }
}

// MARK: - Annotation Window View

struct AnnotationWindowView: View {
    let image: NSImage
    @Bindable var manager: AnnotationManager

    let onCopy: () -> Void
    let onSave: () -> Void
    let onPin: () -> Void
    let onSendToAI: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Canvas
            AnnotationCanvas(
                image: self.image,
                manager: self.manager,
                onComplete: { _ in self.onCopy() },
                onCancel: self.onCancel
            )

            // Toolbar at bottom
            AnnotationToolbar(
                manager: self.manager,
                onCopy: self.onCopy,
                onSave: self.onSave,
                onPin: self.onPin,
                onSendToAI: self.onSendToAI,
                onCancel: self.onCancel
            )
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    let testImage = NSImage(size: CGSize(width: 800, height: 600))
    testImage.lockFocus()
    NSColor.darkGray.setFill()
    NSBezierPath(rect: CGRect(origin: .zero, size: testImage.size)).fill()

    // Draw some test content
    NSColor.white.setFill()
    NSBezierPath(rect: CGRect(x: 100, y: 100, width: 200, height: 150)).fill()

    testImage.unlockFocus()

    return AnnotationWindowView(
        image: testImage,
        manager: AnnotationManager(),
        onCopy: { },
        onSave: { },
        onPin: { },
        onSendToAI: { },
        onCancel: { }
    )
    .frame(width: 800, height: 660)
}
