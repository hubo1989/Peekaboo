import os
import PeekabooCore
import PeekabooFoundation
import PeekabooUICore
import SwiftUI

struct VisualizerSettingsView: View {
    @Bindable var settings: PeekabooSettings
    @Environment(VisualizerCoordinator.self) private var visualizerCoordinator

    private let keyboardThemes = ["classic", "modern", "ghostly"]

    var body: some View {
        Form {
            // Header section with master toggle
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "Visual Feedback"))
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text(String(localized: "Delightful animations for all Peekaboo operations"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: self.$settings.visualizerEnabled)
                        .toggleStyle(IOSToggleStyle())
                }
            }

            // Animation Controls Section
            Section(String(localized: "Animation Settings")) {
                // Animation Speed
                HStack {
                    Label(String(localized: "Animation Speed"), systemImage: "speedometer")
                    Spacer()
                    Text(String(format: "%.1fx", self.settings.visualizerAnimationSpeed))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .frame(width: 40, alignment: .trailing)
                }

                Slider(value: self.$settings.visualizerAnimationSpeed, in: 0.1...2.0, step: 0.1)
                    .disabled(!self.settings.visualizerEnabled)

                // Effect Intensity
                HStack {
                    Label(String(localized: "Effect Intensity"), systemImage: "wand.and.rays")
                    Spacer()
                    Text(String(format: "%.1fx", self.settings.visualizerEffectIntensity))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .frame(width: 40, alignment: .trailing)
                }

                Slider(value: self.$settings.visualizerEffectIntensity, in: 0.1...2.0, step: 0.1)
                    .disabled(!self.settings.visualizerEnabled)

                // Sound Effects
                HStack {
                    Label(String(localized: "Sound Effects"), systemImage: "speaker.wave.2")
                    Spacer()
                    Toggle("", isOn: self.$settings.visualizerSoundEnabled)
                        .toggleStyle(IOSToggleStyle())
                }
                .disabled(!self.settings.visualizerEnabled)

                // Keyboard Theme
                VStack(alignment: .leading, spacing: 8) {
                    Label(String(localized: "Keyboard Theme"), systemImage: "keyboard")
                    Picker("", selection: self.$settings.visualizerKeyboardTheme) {
                        ForEach(self.keyboardThemes, id: \.self) { theme in
                            Text(theme.capitalized).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                    .disabled(!self.settings.visualizerEnabled)
                }
            }
            .opacity(self.settings.visualizerEnabled ? 1 : 0.5)

            // Individual Animations Section
            Section(String(localized: "Animation Types")) {
                AnimationToggleRow(
                    title: String(localized: "Screenshot Flash"),
                    icon: "camera.viewfinder",
                    isOn: self.$settings.screenshotFlashEnabled,
                    isEnabled: self.settings.visualizerEnabled,
                    animationType: "screenshot",
                    settings: self.settings)

                AnimationToggleRow(
                    title: String(localized: "Click Animation"),
                    icon: "cursorarrow.click",
                    isOn: self.$settings.clickAnimationEnabled,
                    isEnabled: self.settings.visualizerEnabled,
                    animationType: "click",
                    settings: self.settings)

                AnimationToggleRow(
                    title: String(localized: "Type Animation"),
                    icon: "keyboard",
                    isOn: self.$settings.typeAnimationEnabled,
                    isEnabled: self.settings.visualizerEnabled,
                    animationType: "type",
                    settings: self.settings)

                AnimationToggleRow(
                    title: String(localized: "Scroll Animation"),
                    icon: "arrow.up.arrow.down",
                    isOn: self.$settings.scrollAnimationEnabled,
                    isEnabled: self.settings.visualizerEnabled,
                    animationType: "scroll",
                    settings: self.settings)

                AnimationToggleRow(
                    title: String(localized: "Mouse Trail"),
                    icon: "scribble",
                    isOn: self.$settings.mouseTrailEnabled,
                    isEnabled: self.settings.visualizerEnabled,
                    animationType: "trail",
                    settings: self.settings)

                AnimationToggleRow(
                    title: String(localized: "Swipe Path"),
                    icon: "hand.draw",
                    isOn: self.$settings.swipePathEnabled,
                    isEnabled: self.settings.visualizerEnabled,
                    animationType: "swipe",
                    settings: self.settings)

                AnimationToggleRow(
                    title: String(localized: "Hotkey Overlay"),
                    icon: "command",
                    isOn: self.$settings.hotkeyOverlayEnabled,
                    isEnabled: self.settings.visualizerEnabled,
                    animationType: "hotkey",
                    settings: self.settings)

                AnimationToggleRow(
                    title: String(localized: "App Lifecycle"),
                    icon: "app.badge",
                    isOn: self.$settings.appLifecycleEnabled,
                    isEnabled: self.settings.visualizerEnabled,
                    animationType: "app_launch",
                    settings: self.settings)

                AnimationToggleRow(
                    title: String(localized: "Window Operations"),
                    icon: "macwindow",
                    isOn: self.$settings.windowOperationEnabled,
                    isEnabled: self.settings.visualizerEnabled,
                    animationType: "window",
                    settings: self.settings)

                AnimationToggleRow(
                    title: String(localized: "Menu Navigation"),
                    icon: "menubar.rectangle",
                    isOn: self.$settings.menuNavigationEnabled,
                    isEnabled: self.settings.visualizerEnabled,
                    animationType: "menu",
                    settings: self.settings)

                AnimationToggleRow(
                    title: String(localized: "Dialog Interaction"),
                    icon: "text.bubble",
                    isOn: self.$settings.dialogInteractionEnabled,
                    isEnabled: self.settings.visualizerEnabled,
                    animationType: "dialog",
                    settings: self.settings)

                AnimationToggleRow(
                    title: String(localized: "Space Transitions"),
                    icon: "squares.below.rectangle",
                    isOn: self.$settings.spaceTransitionEnabled,
                    isEnabled: self.settings.visualizerEnabled,
                    animationType: "space",
                    settings: self.settings)
            }
            .opacity(self.settings.visualizerEnabled ? 1 : 0.5)

            Section(String(localized: "Watch Capture")) {
                AnimationToggleRow(
                    title: String(localized: "Watch Capture HUD"),
                    subtitle: String(localized: "Pulse indicator for `peekaboo watch` sessions"),
                    icon: "applewatch.watchface",
                    isOn: self.$settings.watchCaptureHUDEnabled,
                    isEnabled: self.settings.visualizerEnabled,
                    animationType: "watch",
                    settings: self.settings)
            }
            .opacity(self.settings.visualizerEnabled ? 1 : 0.5)

            // Easter Eggs Section
            Section(String(localized: "Easter Eggs")) {
                AnimationToggleRow(
                    title: String(localized: "Ghost Animation"),
                    subtitle: String(localized: "Shows every 10th screenshot"),
                    icon: "eye.slash",
                    isOn: self.$settings.ghostEasterEggEnabled,
                    isEnabled: self.settings.visualizerEnabled,
                    animationType: "ghost",
                    settings: self.settings)
            }
            .opacity(self.settings.visualizerEnabled ? 1 : 0.5)
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Supporting Views

struct AnimationToggleRow: View {
    let title: String
    var subtitle: String?
    let icon: String
    @Binding var isOn: Bool
    let isEnabled: Bool
    let animationType: String
    let settings: PeekabooSettings

    @Environment(VisualizerCoordinator.self) private var visualizerCoordinator
    @State private var isPreviewRunning = false

    var body: some View {
        HStack {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text(self.title)
                        .foregroundStyle(self.isEnabled ? .primary : .secondary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } icon: {
                Image(systemName: self.icon)
                    .foregroundStyle(self.isEnabled ? Color.accentColor : .secondary)
            }

            Spacer()

            // Preview button
            Button {
                Task {
                    await self.runPreview()
                }
            } label: {
                Image(systemName: self.isPreviewRunning ? "stop.circle" : "play.circle")
                    .foregroundStyle(self.canPreview ? Color.accentColor : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .disabled(!self.canPreview || self.isPreviewRunning)
            .help("Preview \(self.title) animation")

            Toggle("", isOn: self.$isOn)
                .toggleStyle(IOSToggleStyle())
                .disabled(!self.isEnabled)
        }
    }

    private var canPreview: Bool {
        self.isEnabled && self.settings.visualizerEnabled && self.isOn
    }

    @MainActor
    private func runPreview() async {
        self.isPreviewRunning = true
        defer { self.isPreviewRunning = false }

        let screen = NSScreen.mouseScreen
        let centerPoint = CGPoint(x: screen.frame.midX, y: screen.frame.midY)

        await self.performPreview(on: screen, centerPoint: centerPoint)
        // Keep button in running state for a moment to show feedback
        try? await Task.sleep(for: .milliseconds(500))
    }

    @MainActor
    private func performPreview(on screen: NSScreen, centerPoint: CGPoint) async {
        switch self.animationType {
        case "screenshot":
            await self.previewScreenshot(on: screen)
        case "click":
            await self.previewClick(at: centerPoint)
        case "type":
            await self.previewTyping()
        case "scroll":
            await self.previewScroll(at: centerPoint)
        case "trail":
            await self.previewTrail(on: screen)
        case "swipe":
            await self.previewSwipe(on: screen)
        case "hotkey":
            await self.previewHotkey()
        case "app_launch":
            await self.previewAppLifecycle()
        case "window":
            await self.previewWindowMovement(on: screen)
        case "menu":
            await self.previewMenuNavigation()
        case "dialog":
            await self.previewDialog(on: screen)
        case "space":
            await self.previewSpaceSwitch()
        case "ghost":
            await self.previewGhostFlash(on: screen)
        case "watch":
            await self.previewWatchHUD(on: screen)
        default:
            break
        }
    }

    @MainActor
    private func previewScreenshot(on screen: NSScreen) async {
        let rect = CGRect(
            x: screen.frame.midX - 200,
            y: screen.frame.midY - 150,
            width: 400,
            height: 300)
        await self.visualizerCoordinator.runPreview {
            _ = await self.visualizerCoordinator.showScreenshotFlash(in: rect)
        }
    }

    @MainActor
    private func previewClick(at point: CGPoint) async {
        await self.visualizerCoordinator.runPreview {
            _ = await self.visualizerCoordinator.showClickFeedback(at: point, type: .single)
        }
    }

    @MainActor
    private func previewTyping() async {
        let sampleKeys = ["H", "e", "l", "l", "o"]
        await self.visualizerCoordinator.runPreview {
            _ = await self.visualizerCoordinator.showTypingFeedback(
                keys: sampleKeys,
                duration: 2.0,
                cadence: .human(wordsPerMinute: 60))
        }
    }

    @MainActor
    private func previewScroll(at point: CGPoint) async {
        await self.visualizerCoordinator.runPreview {
            _ = await self.visualizerCoordinator.showScrollFeedback(at: point, direction: .down, amount: 3)
        }
    }

    @MainActor
    private func previewTrail(on screen: NSScreen) async {
        let from = CGPoint(x: screen.frame.midX - 150, y: screen.frame.midY - 50)
        let to = CGPoint(x: screen.frame.midX + 150, y: screen.frame.midY + 50)
        await self.visualizerCoordinator.runPreview {
            _ = await self.visualizerCoordinator.showMouseMovement(from: from, to: to, duration: 1.5)
        }
    }

    @MainActor
    private func previewSwipe(on screen: NSScreen) async {
        let swipeFrom = CGPoint(x: screen.frame.midX - 100, y: screen.frame.midY)
        let swipeTo = CGPoint(x: screen.frame.midX + 100, y: screen.frame.midY)
        await self.visualizerCoordinator.runPreview {
            _ = await self.visualizerCoordinator.showSwipeGesture(from: swipeFrom, to: swipeTo, duration: 1.0)
        }
    }

    @MainActor
    private func previewHotkey() async {
        let sampleKeys = ["⌘", "⇧", "P"]
        await self.visualizerCoordinator.runPreview {
            _ = await self.visualizerCoordinator.showHotkeyDisplay(keys: sampleKeys, duration: 2.0)
        }
    }

    @MainActor
    private func previewAppLifecycle() async {
        await self.visualizerCoordinator.runPreview {
            if Bool.random() {
                _ = await self.visualizerCoordinator.showAppLaunch(appName: "Peekaboo", iconPath: nil as String?)
            } else {
                _ = await self.visualizerCoordinator.showAppQuit(appName: "TextEdit", iconPath: nil as String?)
            }
        }
    }

    @MainActor
    private func previewWindowMovement(on screen: NSScreen) async {
        let windowRect = CGRect(
            x: screen.frame.midX - 150,
            y: screen.frame.midY - 100,
            width: 300,
            height: 200)
        await self.visualizerCoordinator.runPreview {
            _ = await self.visualizerCoordinator.showWindowOperation(.move, windowRect: windowRect, duration: 1.0)
        }
    }

    @MainActor
    private func previewMenuNavigation() async {
        let menuPath = ["File", "Export", "PNG Image"]
        await self.visualizerCoordinator.runPreview {
            _ = await self.visualizerCoordinator.showMenuNavigation(menuPath: menuPath)
        }
    }

    @MainActor
    private func previewDialog(on screen: NSScreen) async {
        let dialogRect = CGRect(
            x: screen.frame.midX - 100,
            y: screen.frame.midY - 25,
            width: 200,
            height: 50)
        await self.visualizerCoordinator.runPreview {
            _ = await self.visualizerCoordinator.showDialogInteraction(
                element: .button,
                elementRect: dialogRect,
                action: .clickButton)
        }
    }

    @MainActor
    private func previewSpaceSwitch() async {
        await self.visualizerCoordinator.runPreview {
            _ = await self.visualizerCoordinator.showSpaceSwitch(from: 1, to: 2, direction: .right)
        }
    }

    @MainActor
    private func previewGhostFlash(on screen: NSScreen) async {
        if let window = NSApp.keyWindow {
            _ = await self.visualizerCoordinator.showScreenshotFlash(in: window.frame)
            return
        }

        let rect = CGRect(
            x: screen.frame.midX - 200,
            y: screen.frame.midY - 150,
            width: 400,
            height: 300)
        _ = await self.visualizerCoordinator.showScreenshotFlash(in: rect)
    }

    @MainActor
    private func previewWatchHUD(on screen: NSScreen) async {
        let hudRect = CGRect(
            x: screen.frame.midX - 170,
            y: screen.frame.midY - 150,
            width: 340,
            height: 70)
        _ = await self.visualizerCoordinator.showWatchCapture(in: hudRect)
    }
}

// MARK: - iOS-Style Toggle

struct IOSToggleStyle: ToggleStyle {
    typealias Body = IOSToggleView

    func makeBody(configuration: ToggleStyleConfiguration) -> Body {
        IOSToggleView(configuration: configuration)
    }
}

struct IOSToggleView: View {
    let configuration: ToggleStyleConfiguration

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(self.configuration.isOn ? Color.accentColor : Color(NSColor.tertiaryLabelColor))
            .frame(width: 36, height: 20)
            .overlay(
                Circle()
                    .fill(Color.white)
                    .padding(2)
                    .offset(x: self.configuration.isOn ? 8 : -8)
                    .animation(.spring(response: 0.2, dampingFraction: 0.7), value: self.configuration.isOn))
            .onTapGesture {
                self.configuration.isOn.toggle()
            }
    }
}

#Preview {
    VisualizerSettingsView(settings: PeekabooSettings())
        .frame(width: 650, height: 1000)
}