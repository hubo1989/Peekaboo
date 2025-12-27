//
//  PinWindow.swift
//  Peekaboo
//
//  Created on 2025-12-26.
//

import AppKit
import os.log
import SwiftUI
import UniformTypeIdentifiers

/// A floating pin window that displays a screenshot above other windows
final class PinWindow: NSPanel {
    private let logger = Logger(subsystem: "boo.peekaboo.app", category: "PinWindow")

    /// Unique identifier for this pin window
    let pinID: UUID

    /// The original image being displayed
    let originalImage: NSImage

    /// Current scale factor
    private(set) var scaleFactor: CGFloat = 1.0

    /// Whether mouse click-through is enabled
    private(set) var isClickThroughEnabled: Bool = false

    /// Callback when window is closed
    var onClose: (() -> Void)?

    // MARK: - Initialization

    init(image: NSImage, id: UUID = UUID()) {
        self.pinID = id
        self.originalImage = image

        let contentRect = CGRect(origin: .zero, size: image.size)

        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        self.setupWindow()
        self.setupContentView()
        self.setupTrackingArea()

        self.logger.info("Created pin window: \(id)")
    }

    // MARK: - Window Setup

    private func setupWindow() {
        // Basic appearance
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = true

        // Floating behavior
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Allow movement by dragging background
        self.isMovableByWindowBackground = true

        // Don't show in window menu
        self.isExcludedFromWindowsMenu = true

        // Enable receiving key events
        self.acceptsMouseMovedEvents = true

        // Center on screen initially
        self.center()
    }

    private func setupContentView() {
        let imageView = NSImageView(image: self.originalImage)
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.frame = CGRect(origin: .zero, size: self.originalImage.size)
        imageView.wantsLayer = true
        imageView.layer?.cornerRadius = 6
        imageView.layer?.masksToBounds = true

        // Add a subtle border
        imageView.layer?.borderColor = NSColor.separatorColor.cgColor
        imageView.layer?.borderWidth = 1

        self.contentView = imageView
    }

    private func setupTrackingArea() {
        guard let contentView = self.contentView else { return }

        let trackingArea = NSTrackingArea(
            rect: contentView.bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        contentView.addTrackingArea(trackingArea)
    }

    // MARK: - Scaling

    /// Scale the window by a factor
    func scale(by factor: CGFloat) {
        let newScale = max(0.1, min(5.0, self.scaleFactor * factor))
        self.setScale(newScale)
    }

    /// Set the scale to a specific value
    func setScale(_ scale: CGFloat) {
        self.scaleFactor = scale

        let newSize = CGSize(
            width: self.originalImage.size.width * scale,
            height: self.originalImage.size.height * scale
        )

        // Get current center point
        let currentCenter = CGPoint(
            x: self.frame.midX,
            y: self.frame.midY
        )

        // Calculate new frame centered at the same point
        let newFrame = CGRect(
            x: currentCenter.x - newSize.width / 2,
            y: currentCenter.y - newSize.height / 2,
            width: newSize.width,
            height: newSize.height
        )

        self.setFrame(newFrame, display: true, animate: true)
    }

    /// Reset to original size
    func resetToOriginalSize() {
        self.setScale(1.0)
    }

    // MARK: - Transparency

    /// Set window transparency
    func setTransparency(_ opacity: CGFloat) {
        self.alphaValue = max(0.1, min(1.0, opacity))
    }

    /// Increase transparency (make more transparent)
    func increaseTransparency() {
        self.setTransparency(self.alphaValue - 0.1)
    }

    /// Decrease transparency (make more opaque)
    func decreaseTransparency() {
        self.setTransparency(self.alphaValue + 0.1)
    }

    // MARK: - Click-Through

    /// Enable or disable mouse click-through
    func setClickThrough(_ enabled: Bool) {
        self.isClickThroughEnabled = enabled
        self.ignoresMouseEvents = enabled

        // Add visual indicator when click-through is enabled
        if let imageView = self.contentView as? NSImageView {
            if enabled {
                imageView.layer?.borderColor = NSColor.systemBlue.withAlphaComponent(0.5).cgColor
                imageView.layer?.borderWidth = 2
            } else {
                imageView.layer?.borderColor = NSColor.separatorColor.cgColor
                imageView.layer?.borderWidth = 1
            }
        }

        self.logger.info("Click-through \(enabled ? "enabled" : "disabled") for pin \(self.pinID)")
    }

    // MARK: - Event Handling

    override func scrollWheel(with event: NSEvent) {
        // Zoom with scroll wheel
        let scaleDelta: CGFloat = event.deltaY > 0 ? 1.1 : 0.9
        self.scale(by: scaleDelta)
    }

    override func mouseDown(with event: NSEvent) {
        // Double-click to reset size
        if event.clickCount == 2 {
            self.resetToOriginalSize()
            return
        }

        super.mouseDown(with: event)
    }

    override func rightMouseDown(with event: NSEvent) {
        // Show context menu
        let menu = self.createContextMenu()
        NSMenu.popUpContextMenu(menu, with: event, for: self.contentView!)
    }

    override func keyDown(with event: NSEvent) {
        switch event.charactersIgnoringModifiers {
        case "-":
            self.increaseTransparency()
        case "=", "+":
            self.decreaseTransparency()
        case "w":
            if event.modifierFlags.contains(.command) {
                self.closePin()
            }
        default:
            super.keyDown(with: event)
        }
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    // MARK: - Context Menu

    private func createContextMenu() -> NSMenu {
        let menu = NSMenu()

        // Copy
        let copyItem = NSMenuItem(title: "Copy", action: #selector(self.copyImage), keyEquivalent: "c")
        copyItem.target = self
        menu.addItem(copyItem)

        // Save As...
        let saveItem = NSMenuItem(title: "Save As...", action: #selector(self.saveImage), keyEquivalent: "s")
        saveItem.target = self
        menu.addItem(saveItem)

        menu.addItem(NSMenuItem.separator())

        // Transparency submenu
        let transparencyMenu = NSMenu()
        for opacity in [100, 90, 75, 50, 25] {
            let item = NSMenuItem(
                title: "\(opacity)%",
                action: #selector(self.setTransparencyFromMenu(_:)),
                keyEquivalent: ""
            )
            item.tag = opacity
            item.target = self
            item.state = Int(self.alphaValue * 100) == opacity ? .on : .off
            transparencyMenu.addItem(item)
        }
        let transparencyItem = NSMenuItem(title: "Transparency", action: nil, keyEquivalent: "")
        transparencyItem.submenu = transparencyMenu
        menu.addItem(transparencyItem)

        // Click-through toggle
        let clickThroughItem = NSMenuItem(
            title: "Mouse Click-Through",
            action: #selector(self.toggleClickThrough),
            keyEquivalent: ""
        )
        clickThroughItem.target = self
        clickThroughItem.state = self.isClickThroughEnabled ? .on : .off
        menu.addItem(clickThroughItem)

        // Show on all spaces
        let allSpacesItem = NSMenuItem(
            title: "Show on All Spaces",
            action: #selector(self.toggleAllSpaces),
            keyEquivalent: ""
        )
        allSpacesItem.target = self
        allSpacesItem.state = self.collectionBehavior.contains(.canJoinAllSpaces) ? .on : .off
        menu.addItem(allSpacesItem)

        menu.addItem(NSMenuItem.separator())

        // Reset size
        let resetItem = NSMenuItem(title: "Reset Size", action: #selector(self.resetSize), keyEquivalent: "")
        resetItem.target = self
        menu.addItem(resetItem)

        menu.addItem(NSMenuItem.separator())

        // Close
        let closeItem = NSMenuItem(title: "Close", action: #selector(self.closePin), keyEquivalent: "w")
        closeItem.target = self
        menu.addItem(closeItem)

        // Close All
        let closeAllItem = NSMenuItem(title: "Close All Pins", action: #selector(self.closeAllPins), keyEquivalent: "")
        closeAllItem.target = self
        menu.addItem(closeAllItem)

        return menu
    }

    // MARK: - Menu Actions

    @objc private func copyImage() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        if let tiffData = self.originalImage.tiffRepresentation {
            pasteboard.setData(tiffData, forType: .tiff)
            self.logger.info("Copied pin image to clipboard")
        }
    }

    @objc private func saveImage() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png, .jpeg]
        savePanel.nameFieldStringValue = "Pin-\(Self.timestampString())"

        savePanel.begin { [weak self] response in
            guard response == .OK, let url = savePanel.url, let self = self else { return }

            guard let tiffData = self.originalImage.tiffRepresentation,
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
                self.logger.info("Saved pin image to \(url.path)")
            } catch {
                self.logger.error("Failed to save pin image: \(error.localizedDescription)")
            }
        }
    }

    @objc private func setTransparencyFromMenu(_ sender: NSMenuItem) {
        let opacity = CGFloat(sender.tag) / 100.0
        self.setTransparency(opacity)
    }

    @objc private func toggleClickThrough() {
        self.setClickThrough(!self.isClickThroughEnabled)
    }

    @objc private func toggleAllSpaces() {
        if self.collectionBehavior.contains(.canJoinAllSpaces) {
            self.collectionBehavior.remove(.canJoinAllSpaces)
        } else {
            self.collectionBehavior.insert(.canJoinAllSpaces)
        }
    }

    @objc private func resetSize() {
        self.resetToOriginalSize()
    }

    @objc private func closePin() {
        self.logger.info("Closing pin window: \(self.pinID)")
        self.onClose?()
        self.orderOut(nil)
    }

    @objc private func closeAllPins() {
        // This will be handled by PinWindowManager
        NotificationCenter.default.post(name: .closeAllPinWindows, object: nil)
    }

    // MARK: - Helpers

    private static func timestampString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter.string(from: Date())
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let closeAllPinWindows = Notification.Name("closeAllPinWindows")
}
