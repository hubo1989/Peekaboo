## ADDED Requirements

### Requirement: Global Screenshot Shortcuts
The system SHALL provide configurable global keyboard shortcuts for triggering screenshot operations.

#### Scenario: Capture area with shortcut
- **WHEN** user presses the "Capture Area" shortcut (default: Cmd+Shift+A)
- **THEN** the system SHALL display a full-screen selection overlay
- **AND** the user can drag to select a region

#### Scenario: Capture full screen with shortcut
- **WHEN** user presses the "Capture Screen" shortcut (default: Cmd+Shift+S)
- **THEN** the system SHALL capture the entire main display immediately

#### Scenario: Capture window with shortcut
- **WHEN** user presses the "Capture Window" shortcut (default: Cmd+Shift+W)
- **THEN** the system SHALL highlight windows on hover
- **AND** clicking a window captures only that window

#### Scenario: Repeat last capture
- **WHEN** user presses the "Repeat Last Capture" shortcut (default: Cmd+Shift+R)
- **THEN** the system SHALL capture the same region as the previous capture

### Requirement: Shortcut Customization
The system SHALL allow users to customize all screenshot-related shortcuts in Settings.

#### Scenario: Configure shortcut in Settings
- **WHEN** user opens Settings > Shortcuts
- **THEN** the system SHALL display all screenshot shortcuts with current bindings
- **AND** user can click to record a new shortcut combination

#### Scenario: Clear shortcut
- **WHEN** user clicks "Clear" on a shortcut
- **THEN** the system SHALL remove the shortcut binding
- **AND** the shortcut becomes inactive

### Requirement: Shortcut Conflict Detection
The system SHALL detect and warn about conflicting keyboard shortcuts.

#### Scenario: Duplicate shortcut warning
- **WHEN** user assigns a shortcut that is already in use
- **THEN** the system SHALL display a warning message
- **AND** offer to replace the existing binding
