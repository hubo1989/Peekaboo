import AppKit
import PeekabooCore
import SwiftUI

// MARK: - Header Components

/// Compact, macOS-native header for the menu bar popover.
struct StatusBarHeaderView: View {
    @Environment(PeekabooAgent.self) private var agent
    @Environment(SessionStore.self) private var sessionStore

    let onOpenMainWindow: () -> Void
    let onOpenInspector: () -> Void
    let onOpenSettings: () -> Void
    let onNewSession: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image("MenuIcon")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(.secondary)
                .frame(width: 16, height: 16)

            VStack(alignment: .leading, spacing: 1) {
                Text(String(localized: "Peekaboo"))
                    .font(.headline)

                Text(self.subtitleText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            if self.agent.isProcessing {
                Button(role: .destructive) {
                    self.agent.cancelCurrentTask()
                } label: {
                    Image(systemName: "stop.circle.fill")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.borderless)
                .help(String(localized: "Cancel"))
            }

            Menu {
                Button(String(localized: "Open Peekaboo")) { self.onOpenMainWindow() }
                Button(String(localized: "New Session")) { self.onNewSession() }

                Divider()

                Button(String(localized: "Inspector")) { self.onOpenInspector() }
                Button(String(localized: "Settings…")) { self.onOpenSettings() }

                Divider()

                Button(String(localized: "About Peekaboo")) { NSApp.orderFrontStandardAboutPanel(nil) }
                Button(String(localized: "Quit Peekaboo")) { NSApp.terminate(nil) }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(.secondary)
            }
            .menuStyle(.borderlessButton)
            .help(String(localized: "Menu"))
        }
    }

    private var subtitleText: String {
        if self.agent.isProcessing {
            return String(localized: "Working…")
        }

        if let session = self.sessionStore.currentSession {
            return session.title
        }

        return String(localized: "Ready")
    }
}