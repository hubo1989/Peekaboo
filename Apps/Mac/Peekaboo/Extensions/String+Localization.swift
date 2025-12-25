//
//  String+Localization.swift
//  Peekaboo
//
//  Localization helper for Peekaboo Mac app
//

import Foundation

extension String {
    /// Returns a localized version of the string using the app's Localizable.xcstrings
    ///
    /// Usage:
    /// ```swift
    /// let title = "Screen Recording".localized
    /// let message = "Grant".localized
    /// ```
    var localized: String {
        String(localized: LocalizationValue(self))
    }
}

// MARK: - Localization Keys

/// Centralized localization keys for type-safe access
enum LocalizedStrings {
    // MARK: - Permissions

    enum Permissions {
        static let screenRecording = String(localized: "Screen Recording")
        static let accessibility = String(localized: "Accessibility")
        static let automation = String(localized: "Automation (AppleScript)")
        static let grant = String(localized: "Grant")
        static let granted = String(localized: "Granted")
        static let refresh = String(localized: "Refresh")
        static let refreshStatus = String(localized: "Refresh status")
        static let optional = String(localized: "Optional")

        static let screenRecordingDescription = String(
            localized: "Capture screenshots and see on-screen context")
        static let accessibilityDescription = String(
            localized: "Control UI elements, mouse, and keyboard")
        static let automationDescription = String(
            localized: "Control apps via Apple Events (optional)")
    }

    // MARK: - Settings Tabs

    enum SettingsTabs {
        static let general = String(localized: "General")
        static let ai = String(localized: "AI")
        static let visualizer = String(localized: "Visualizer")
        static let shortcuts = String(localized: "Shortcuts")
        static let permissions = String(localized: "Permissions")
        static let about = String(localized: "About")
    }

    // MARK: - General Settings

    enum GeneralSettings {
        static let launchAtLogin = String(localized: "Launch at login")
        static let showInDock = String(localized: "Show in Dock")
        static let keepWindowOnTop = String(localized: "Keep window on top")
        static let features = String(localized: "Features")
        static let enableAgentMode = String(localized: "Enable agent mode")
        static let enableHapticFeedback = String(localized: "Enable haptic feedback")
        static let enableSoundEffects = String(localized: "Enable sound effects")
    }

    // MARK: - AI Settings

    enum AISettings {
        static let modelSelection = String(localized: "Model Selection")
        static let model = String(localized: "Model")
        static let openAIConfiguration = String(localized: "OpenAI Configuration")
        static let anthropicConfiguration = String(localized: "Anthropic Configuration")
        static let ollamaConfiguration = String(localized: "Ollama Configuration")
        static let baseURL = String(localized: "Base URL")
        static let ensureOllamaRunning = String(localized: "Ensure Ollama is running locally")
        static let parameters = String(localized: "Parameters")
        static let temperature = String(localized: "Temperature")
        static let maxTokens = String(localized: "Max Tokens")
        static let visionModelOverride = String(localized: "Vision Model Override")
        static let visionModel = String(localized: "Vision Model")
        static let useCustomVisionModel = String(localized: "Use custom model for vision tasks")
        static let customProviders = String(localized: "Custom Providers")
    }

    // MARK: - Common

    enum Common {
        static let settings = String(localized: "Settings")
        static let newSession = String(localized: "New Session")
    }
}
