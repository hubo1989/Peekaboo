//
//  PinWindowManager.swift
//  Peekaboo
//
//  Created on 2025-12-26.
//

import AppKit
import Observation
import os.log

/// Manages multiple pin windows and their lifecycle
@Observable
@MainActor
final class PinWindowManager {
    private let logger = Logger(subsystem: "boo.peekaboo.app", category: "PinWindowManager")

    /// All active pin windows
    private(set) var pinWindows: [UUID: PinWindow] = [:]

    /// Whether there are any open pin windows
    var hasPinWindows: Bool { !self.pinWindows.isEmpty }

    /// Number of open pin windows
    var pinWindowCount: Int { self.pinWindows.count }

    // MARK: - Initialization

    init() {
        self.setupNotificationObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public API

    /// Create and show a new pin window with the given image
    func createPinWindow(with image: NSImage) -> PinWindow {
        let pinWindow = PinWindow(image: image)

        pinWindow.onClose = { [weak self, weak pinWindow] in
            guard let self = self, let pinWindow = pinWindow else { return }
            self.removePinWindow(id: pinWindow.pinID)
        }

        self.pinWindows[pinWindow.pinID] = pinWindow
        pinWindow.makeKeyAndOrderFront(nil)

        // Offset from center if there are multiple pins
        if self.pinWindows.count > 1 {
            self.offsetFromCenter(pinWindow)
        }

        self.logger.info("Created pin window \(pinWindow.pinID). Total: \(self.pinWindows.count)")
        return pinWindow
    }

    /// Close a specific pin window
    func closePinWindow(id: UUID) {
        guard let window = self.pinWindows[id] else { return }
        window.orderOut(nil)
        self.removePinWindow(id: id)
    }

    /// Close all pin windows
    func closeAllPinWindows() {
        self.logger.info("Closing all \(self.pinWindows.count) pin windows")

        for (_, window) in self.pinWindows {
            window.orderOut(nil)
        }
        self.pinWindows.removeAll()
    }

    /// Get a pin window by ID
    func getPinWindow(id: UUID) -> PinWindow? {
        self.pinWindows[id]
    }

    /// Bring all pin windows to front
    func bringAllToFront() {
        for (_, window) in self.pinWindows {
            window.orderFront(nil)
        }
    }

    // MARK: - Private Methods

    private func removePinWindow(id: UUID) {
        self.pinWindows.removeValue(forKey: id)
        self.logger.info("Removed pin window \(id). Remaining: \(self.pinWindows.count)")
    }

    private func offsetFromCenter(_ window: PinWindow) {
        let offset = CGFloat(self.pinWindows.count - 1) * 30
        var frame = window.frame
        frame.origin.x += offset
        frame.origin.y -= offset
        window.setFrame(frame, display: false)
    }

    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: .closeAllPinWindows,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.closeAllPinWindows()
            }
        }
    }

    // MARK: - Persistence (Optional Feature)

    /// Save pin window state for restoration
    func savePinState() -> [[String: Any]] {
        var state: [[String: Any]] = []

        for (id, window) in self.pinWindows {
            var pinState: [String: Any] = [
                "id": id.uuidString,
                "frame": NSStringFromRect(window.frame),
                "scale": window.scaleFactor,
                "opacity": window.alphaValue,
                "clickThrough": window.isClickThroughEnabled
            ]

            // Save image data
            if let tiffData = window.originalImage.tiffRepresentation {
                pinState["imageData"] = tiffData
            }

            state.append(pinState)
        }

        return state
    }

    /// Restore pin windows from saved state
    func restorePinState(_ state: [[String: Any]]) {
        for pinState in state {
            guard let idString = pinState["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let imageData = pinState["imageData"] as? Data,
                  let image = NSImage(data: imageData) else {
                continue
            }

            let window = PinWindow(image: image, id: id)

            // Restore frame
            if let frameString = pinState["frame"] as? String {
                let frame = NSRectFromString(frameString)
                window.setFrame(frame, display: false)
            }

            // Restore scale
            if let scale = pinState["scale"] as? CGFloat {
                window.setScale(scale)
            }

            // Restore opacity
            if let opacity = pinState["opacity"] as? CGFloat {
                window.setTransparency(opacity)
            }

            // Restore click-through
            if let clickThrough = pinState["clickThrough"] as? Bool {
                window.setClickThrough(clickThrough)
            }

            window.onClose = { [weak self] in
                self?.removePinWindow(id: id)
            }

            self.pinWindows[id] = window
            window.makeKeyAndOrderFront(nil)
        }

        self.logger.info("Restored \(state.count) pin windows")
    }
}

// MARK: - Singleton Access

extension PinWindowManager {
    /// Shared instance for app-wide access
    @MainActor
    static let shared = PinWindowManager()
}
