import SwiftUI

// MARK: - Action Components

/// Bottom action buttons view (compact, macOS-native).
struct ActionButtonsView: View {
    let onOpenMainWindow: () -> Void
    let onNewSession: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(String(localized: "Open Peekaboo")) {
                self.onOpenMainWindow()
            }
            .buttonStyle(.borderedProminent)

            Button(String(localized: "New Session")) {
                self.onNewSession()
            }
            .buttonStyle(.bordered)
        }
    }
}