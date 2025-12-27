//
//  KeyboardShortcutNames.swift
//  Peekaboo
//

import AppKit
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    // MARK: - App Shortcuts
    static let togglePopover = Self("togglePopover", default: .init(.space, modifiers: [.command, .shift]))
    static let showMainWindow = Self("showMainWindow", default: .init(.p, modifiers: [.command, .shift]))
    static let showInspector = Self("showInspector", default: .init(.i, modifiers: [.command, .shift]))

    // MARK: - Screenshot Shortcuts
    static let captureArea = Self("captureArea", default: .init(.a, modifiers: [.command, .shift]))
    static let captureScreen = Self("captureScreen", default: .init(.s, modifiers: [.command, .shift]))
    static let captureWindow = Self("captureWindow", default: .init(.w, modifiers: [.command, .shift]))
    static let repeatLastCapture = Self("repeatLastCapture", default: .init(.r, modifiers: [.command, .shift]))
}
