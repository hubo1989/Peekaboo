//
//  ScreenshotCoordinator.swift
//  Peekaboo
//
//  Created on 2025-12-26.
//

import AppKit
import Observation
import os.log
import PeekabooAutomation
import PeekabooAutomationKit
import ScreenCaptureKit
import UniformTypeIdentifiers

/// Capture mode for screenshot operations
enum ScreenshotCaptureMode: Equatable {
    case area
    case screen
    case window
    case repeatLast
}

/// State machine for screenshot workflow
enum ScreenshotState: Equatable {
    case idle
    case selecting(mode: ScreenshotCaptureMode)
    case annotating
    case done
}

/// Coordinates the screenshot capture workflow including selection, annotation, and output.
@Observable
@MainActor
final class ScreenshotCoordinator {
    // MARK: - Properties

    private let logger = Logger(subsystem: "boo.peekaboo.app", category: "ScreenshotCoordinator")

    /// Current state of the screenshot workflow
    private(set) var state: ScreenshotState = .idle

    /// The captured image (after selection, before/during annotation)
    var capturedImage: NSImage?

    /// The selected region for repeat capture
    private var lastCapturedRegion: CGRect?

    /// The last capture mode used
    private var lastCaptureMode: ScreenshotCaptureMode?

    /// Selection window for area capture
    private var selectionWindow: SelectionWindow?

    /// Annotation window controller
    private var annotationWindowController: AnnotationWindowController?

    /// Reference to settings
    private weak var settings: PeekabooSettings?

    // MARK: - Initialization

    init(settings: PeekabooSettings? = nil) {
        self.settings = settings
    }

    // MARK: - Public API

    /// Start area capture mode
    func startAreaCapture() {
        guard self.state == .idle else {
            self.logger.warning("Cannot start area capture: not in idle state")
            return
        }

        self.logger.info("Starting area capture")
        // We set state to selecting immediately to prevent re-entry,
        // but we'll capture screens asynchronously
        self.state = .selecting(mode: .area)

        Task {
            let images = await self.captureAllScreens()
            await MainActor.run {
                // Ensure we are still in the correct state (user might have cancelled)
                if case .selecting(let mode) = self.state, mode == .area {
                    self.showSelectionOverlay(with: images)
                }
            }
        }
    }

    /// Start full screen capture
    func startScreenCapture() {
        guard self.state == .idle else {
            self.logger.warning("Cannot start screen capture: not in idle state")
            return
        }

        self.logger.info("Starting screen capture")
        self.state = .selecting(mode: .screen)
        self.captureFullScreen()
    }

    /// Start window capture mode
    func startWindowCapture() {
        guard self.state == .idle else {
            self.logger.warning("Cannot start window capture: not in idle state")
            return
        }

        self.logger.info("Starting window capture")
        self.state = .selecting(mode: .window)
        self.showWindowSelectionOverlay()
    }

    /// Repeat the last capture
    func repeatLastCapture() {
        guard self.state == .idle else {
            self.logger.warning("Cannot repeat capture: not in idle state")
            return
        }

        guard let lastMode = self.lastCaptureMode else {
            self.logger.info("No previous capture to repeat, defaulting to area capture")
            self.startAreaCapture()
            return
        }

        self.logger.info("Repeating last capture: \(String(describing: lastMode))")

        switch lastMode {
        case .area:
            if let region = self.lastCapturedRegion {
                self.state = .selecting(mode: .repeatLast)
                self.captureRegion(region)
            } else {
                self.startAreaCapture()
            }
        case .screen:
            self.startScreenCapture()
        case .window:
            self.startWindowCapture()
        case .repeatLast:
            self.startAreaCapture()
        }
    }

    /// Cancel the current capture operation
    func cancelCapture() {
        self.logger.info("Cancelling capture")
        self.dismissSelectionOverlay()
        self.dismissAnnotationWindow()
        self.state = .idle
        self.capturedImage = nil
    }

    /// Complete the capture with the selected region
    func completeSelection(region: CGRect) {
        self.logger.info("Selection completed: \(region.debugDescription)")
        self.lastCapturedRegion = region

        if case .selecting(let mode) = self.state {
            self.lastCaptureMode = mode
        }

        self.dismissSelectionOverlay()
        self.captureRegion(region)
    }

    /// Transition to annotation mode
    func enterAnnotationMode() {
        guard let image = self.capturedImage else {
            self.logger.error("Cannot enter annotation mode: no captured image")
            return
        }

        self.logger.info("Entering annotation mode")
        self.state = .annotating

        // Show annotation window
        self.annotationWindowController = AnnotationWindowController(image: image, coordinator: self)
        self.annotationWindowController?.show()
    }

    /// Dismiss annotation window
    func dismissAnnotationWindow() {
        self.annotationWindowController?.dismiss()
        // Delay clearing the reference to allow window cleanup to complete
        let controller = self.annotationWindowController
        self.annotationWindowController = nil
        DispatchQueue.main.async {
            _ = controller?.description
        }
    }

    /// Complete the workflow
    func completeCapture() {
        self.logger.info("Capture workflow completed")
        // Reset state directly to idle - no delay needed
        // Using Task with delay caused issues in Release builds where
        // the state could get stuck in .done, preventing subsequent captures
        self.state = .idle
        self.capturedImage = nil
    }

    // MARK: - Output Actions

    /// Copy the captured image to clipboard
    func copyToClipboard() {
        guard let image = self.capturedImage else {
            self.logger.warning("No image to copy")
            return
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        if let tiffData = image.tiffRepresentation {
            pasteboard.setData(tiffData, forType: .tiff)
            self.logger.info("Image copied to clipboard")
        }

        self.completeCapture()
    }

    /// Save the captured image to file
    func saveToFile() {
        guard let image = self.capturedImage else {
            self.logger.warning("No image to save")
            return
        }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png, .jpeg]
        savePanel.nameFieldStringValue = String(localized: "Screenshot-\(Self.timestampString())")

        if let location = self.settings?.screenshotDefaultSaveLocation {
            savePanel.directoryURL = URL(fileURLWithPath: (location as NSString).expandingTildeInPath)
        }

        savePanel.begin { response in
            guard response == .OK, let url = savePanel.url else { return }

            Task { @MainActor in
                self.saveImage(image, to: url)
                self.completeCapture()
            }
        }
    }

    /// Pin the captured image to desktop
    func pinToDesktop() {
        guard let image = self.capturedImage else {
            self.logger.warning("No image to pin")
            return
        }

        self.logger.info("Pinning image to desktop")
        _ = PinWindowManager.shared.createPinWindow(with: image)
        self.completeCapture()
    }

    /// Send the captured image to AI for analysis
    func sendToAI() {
        guard let image = self.capturedImage else {
            self.logger.warning("No image to send to AI")
            return
        }

        self.logger.info("Sending image to AI")

        Task {
            // Optimize image for AI: resize and compress
            let optimizedImage = self.optimizeImageForAI(image)

            guard let jpegData = self.jpegData(from: optimizedImage) else {
                self.logger.error("Failed to convert image to JPEG")
                await MainActor.run { self.completeCapture() }
                return
            }

            self.logger.info("Image prepared for AI. Original: \(image.size.width)x\(image.size.height), Optimized: \(optimizedImage.size.width)x\(optimizedImage.size.height)")

            do {
                let service = PeekabooAIService()
                let result = try await service.analyzeImage(
                    imageData: jpegData,
                    question: String(localized: "Please analyze this screenshot. Describe what you see and extract any text.")
                )

                self.logger.info("AI analysis successful")

                await MainActor.run {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(result, forType: .string)
                    self.logger.info("AI response copied to clipboard")
                    self.completeCapture()
                }
            } catch {
                self.logger.error("AI analysis failed: \(error.localizedDescription)")
                await MainActor.run { self.completeCapture() }
            }
        }
    }

    // MARK: - Private Methods

    private func optimizeImageForAI(_ image: NSImage) -> NSImage {
        let maxDimension: CGFloat = 2048
        let size = image.size

        // Check if resizing is needed
        if size.width <= maxDimension && size.height <= maxDimension {
            return image
        }

        // Calculate new size maintaining aspect ratio
        let aspectRatio = size.width / size.height
        var newSize: CGSize

        if size.width > size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }

        // Create resized image
        let newImage = NSImage(size: newSize)

        newImage.lockFocus()
        // High quality interpolation
        NSGraphicsContext.current?.imageInterpolation = .high
        image.draw(in: CGRect(origin: .zero, size: newSize), from: CGRect(origin: .zero, size: size), operation: .copy, fraction: 1.0)
        newImage.unlockFocus()

        return newImage
    }

    private func jpegData(from image: NSImage, compressionQuality: CGFloat = 0.8) -> Data? {
        guard let tiffRepresentation = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else {
            return nil
        }

        return bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
    }

    private func showSelectionOverlay(with images: [NSScreen: NSImage] = [:]) {
        self.selectionWindow = SelectionWindow(coordinator: self)
        self.selectionWindow?.setScreenImages(images)
        self.selectionWindow?.showOverlay()
    }

    private func showWindowSelectionOverlay() {
        // TODO: Implement window selection mode
        self.selectionWindow = SelectionWindow(coordinator: self, mode: .window)
        self.selectionWindow?.showOverlay()
    }

    private func dismissSelectionOverlay() {
        self.selectionWindow?.dismissOverlay()
        self.selectionWindow = nil
    }

    private func captureFullScreen() {
        Task {
            do {
                let screenRect = NSScreen.main?.frame ?? .zero
                let image = try await self.captureScreen(rect: screenRect)
                self.capturedImage = image
                self.lastCaptureMode = .screen

                if self.settings?.screenshotShowAnnotationToolbar == true {
                    self.enterAnnotationMode()
                } else {
                    self.copyToClipboard()
                }
            } catch {
                self.logger.error("Screen capture failed: \(error.localizedDescription)")
                self.cancelCapture()
            }
        }
    }

    private func captureRegion(_ region: CGRect) {
        Task {
            do {
                let image = try await self.captureScreen(rect: region)
                self.capturedImage = image

                if self.settings?.screenshotShowAnnotationToolbar == true {
                    self.enterAnnotationMode()
                } else {
                    self.copyToClipboard()
                }
            } catch {
                self.logger.error("Region capture failed: \(error.localizedDescription)")
                self.cancelCapture()
            }
        }
    }

    private func captureAllScreens() async -> [NSScreen: NSImage] {
        var images: [NSScreen: NSImage] = [:]

        for screen in NSScreen.screens {
            if let displayID = screen.displayID,
               let image = try? await self.captureScreen(rect: screen.frame, displayID: displayID) {
                images[screen] = image
            }
        }

        return images
    }

    private func captureScreen(rect: CGRect, displayID: CGDirectDisplayID? = nil) async throws -> NSImage {
        // Use ScreenCaptureKit for screen capture (required for macOS 15+)
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)

        let display: SCDisplay
        if let targetID = displayID {
            guard let match = content.displays.first(where: { $0.displayID == targetID }) else {
                throw ScreenshotError.captureFailure
            }
            display = match
        } else {
            guard let first = content.displays.first else {
                throw ScreenshotError.captureFailure
            }
            display = first
        }

        let filter = SCContentFilter(display: display, excludingWindows: [])

        // Calculate scale factor for retina displays to ensure high clarity
        // Find the screen that contains the rect center
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let screen = NSScreen.screens.first(where: { NSMouseInRect(center, $0.frame, false) }) ?? NSScreen.main
        let scaleFactor = screen?.backingScaleFactor ?? 1.0

        let config = SCStreamConfiguration()
        config.width = Int(rect.width * scaleFactor)
        config.height = Int(rect.height * scaleFactor)
        config.sourceRect = rect
        config.scalesToFit = false
        config.showsCursor = false

        let cgImage = try await SCScreenshotManager.captureImage(
            contentFilter: filter,
            configuration: config
        )

        // Create NSImage with correct DPI handling
        return NSImage(cgImage: cgImage, size: rect.size)
    }

    private func saveImage(_ image: NSImage, to url: URL) {
        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData) else {
            self.logger.error("Failed to create bitmap representation")
            return
        }

        let format = self.settings?.screenshotImageFormat ?? "png"
        let fileType: NSBitmapImageRep.FileType = format == "jpeg" ? .jpeg : .png

        guard let imageData = bitmapRep.representation(using: fileType, properties: [:]) else {
            self.logger.error("Failed to create image data")
            return
        }

        do {
            try imageData.write(to: url)
            self.logger.info("Image saved to \(url.path)")
        } catch {
            self.logger.error("Failed to save image: \(error.localizedDescription)")
        }
    }

    private static func timestampString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter.string(from: Date())
    }
}

// MARK: - Errors

enum ScreenshotError: Error, LocalizedError {
    case captureFailure
    case noSelection

    var errorDescription: String? {
        switch self {
        case .captureFailure:
            return String(localized: "Failed to capture screen")
        case .noSelection:
            return String(localized: "No region selected")
        }
    }
}

private extension NSScreen {
    var displayID: CGDirectDisplayID? {
        return deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID
    }
}
