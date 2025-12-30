//
//  ShortcutSettingsView.swift
//  Peekaboo
//
//  Created by Claude on 2025-08-04.
//

import KeyboardShortcuts
import PeekabooCore
import SwiftUI

struct ShortcutSettingsView: View {
    var body: some View {
        Form {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "Keyboard Shortcuts"))
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text(String(localized: "Customize global keyboard shortcuts for quick access"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }

            Section(String(localized: "App Shortcuts")) {
                VStack(spacing: 16) {
                    ShortcutRecorderView(
                        title: String(localized: "Toggle Popover"),
                        shortcutName: .togglePopover)

                    Divider()

                    ShortcutRecorderView(
                        title: String(localized: "Show Main Window"),
                        shortcutName: .showMainWindow)

                    Divider()

                    ShortcutRecorderView(
                        title: String(localized: "Show Inspector"),
                        shortcutName: .showInspector)
                }
                .padding(.vertical, 8)
            }

            Section(String(localized: "Screenshot Shortcuts")) {
                VStack(spacing: 16) {
                    ShortcutRecorderView(
                        title: String(localized: "Capture Area"),
                        shortcutName: .captureArea)

                    Divider()

                    ShortcutRecorderView(
                        title: String(localized: "Capture Screen"),
                        shortcutName: .captureScreen)

                    Divider()

                    ShortcutRecorderView(
                        title: String(localized: "Capture Window"),
                        shortcutName: .captureWindow)

                    Divider()

                    ShortcutRecorderView(
                        title: String(localized: "Repeat Last Capture"),
                        shortcutName: .repeatLastCapture)
                }
                .padding(.vertical, 8)
            }

            Section(String(localized: "Instructions")) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text(String(localized: "How to record shortcuts:"))
                            .font(.headline)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Label(String(localized: "Click \"Record\" next to any shortcut"), systemImage: "1.circle")
                        Label(String(localized: "Press your desired key combination"), systemImage: "2.circle")
                        Label(String(localized: "Click \"Done\" to save or \"Cancel\" to abort"), systemImage: "3.circle")
                        Label(String(localized: "Use \"Clear\" to remove a shortcut entirely"), systemImage: "4.circle")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)

                    Divider()
                        .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "Tips:"))
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text(String(localized: "• Shortcuts must include at least one modifier key (⌘, ⌥, ⌃, or ⇧)"))
                        Text(String(localized: "• Avoid common system shortcuts like ⌘Space or ⌘Tab"))
                        Text(String(localized: "• Changes take effect immediately without restart"))
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

#Preview {
    ShortcutSettingsView()
        .frame(width: 650, height: 600)
}