//
//  SelectionWindow.swift
//  Peekaboo
//
//  Created on 2025-12-26.
//

import AppKit
import os.log
import SwiftUI

/// Selection mode for the overlay
enum SelectionMode {
    case area
    case window
}

/// A borderless full-screen window for selecting screenshot regions.
@MainActor
final class SelectionWindow {
    private let logger = Logger(subsystem: "boo.peekaboo.app", category: "SelectionWindow")

    private var windows: [NSWindow] = []
    private var eventMonitor: Any?
    private weak var coordinator: ScreenshotCoordinator?
    private let mode: SelectionMode
    private var screenImages: [NSScreen: NSImage] = [:]

    init(coordinator: ScreenshotCoordinator, mode: SelectionMode = .area) {
        self.coordinator = coordinator
        self.mode = mode
    }

    /// Set the background images for each screen
    func setScreenImages(_ images: [NSScreen: NSImage]) {
        self.screenImages = images
    }

    /// Show the selection overlay on all screens
    func showOverlay() {
        self.logger.info("Showing selection overlay")

        // Create a window for each screen
        for screen in NSScreen.screens {
            let window = self.createOverlayWindow(for: screen)
            self.windows.append(window)
            window.makeKeyAndOrderFront(nil)
        }

        // Make sure the app is active
        NSApp.activate(ignoringOtherApps: true)

        // Set up escape key monitoring
        self.eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // ESC key
                self?.coordinator?.cancelCapture()
                return nil
            }
            return event
        }
    }

    /// Dismiss the selection overlay
    func dismissOverlay() {
        self.logger.info("Dismissing selection overlay")

        if let monitor = self.eventMonitor {
            NSEvent.removeMonitor(monitor)
            self.eventMonitor = nil
        }

        for window in self.windows {
            window.orderOut(nil)
        }
        self.windows.removeAll()
    }

    private func createOverlayWindow(for screen: NSScreen) -> NSWindow {
        let window = SelectionOverlayWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false,
            screen: screen
        )

        window.level = .screenSaver
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.ignoresMouseEvents = false
        window.acceptsMouseMovedEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.onCancel = { [weak self] in
            self?.coordinator?.cancelCapture()
        }

        let contentView = SelectionOverlayView(
            coordinator: self.coordinator,
            screenFrame: screen.frame,
            mode: self.mode,
            backgroundImage: self.screenImages[screen]
        )

        window.contentView = NSHostingView(rootView: contentView)

        return window
    }
}

/// Custom window to handle cancel operation (ESC key)
private class SelectionOverlayWindow: NSWindow {
    var onCancel: (() -> Void)?

    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return true
    }

    override func cancelOperation(_ sender: Any?) {
        self.onCancel?()
    }
}
