## ADDED Requirements

### Requirement: Floating Pin Window
The system SHALL provide floating windows to display pinned screenshots above other windows.

#### Scenario: Create pin window
- **WHEN** user pins a screenshot
- **THEN** the system SHALL create a borderless floating window
- **AND** display the screenshot at its original size
- **AND** the window stays on top of other windows

#### Scenario: Drag pin window
- **WHEN** user drags a pin window by its content
- **THEN** the system SHALL move the window to the new position
- **AND** remember the position for the session

### Requirement: Pin Window Scaling
The system SHALL support scaling pinned screenshots.

#### Scenario: Zoom with scroll wheel
- **WHEN** user scrolls the mouse wheel over a pin window
- **THEN** the system SHALL scale the window and its content
- **AND** maintain aspect ratio

#### Scenario: Reset to original size
- **WHEN** user double-clicks on a pin window
- **THEN** the system SHALL reset the window to the original screenshot size

### Requirement: Pin Window Transparency
The system SHALL allow adjusting the transparency of pin windows.

#### Scenario: Adjust transparency via menu
- **WHEN** user selects a transparency level from the context menu
- **THEN** the system SHALL apply the selected opacity to the pin window

#### Scenario: Keyboard transparency control
- **WHEN** user presses - or + while a pin window is focused
- **THEN** the system SHALL decrease or increase the window transparency

### Requirement: Mouse Click-Through
The system SHALL support mouse click-through mode for pin windows.

#### Scenario: Enable click-through
- **WHEN** user enables "Mouse Click-Through" from the context menu
- **THEN** the system SHALL allow mouse clicks to pass through the pin window
- **AND** the window becomes non-interactive except for the context menu

#### Scenario: Disable click-through
- **WHEN** user right-clicks on a click-through pin window and disables the option
- **THEN** the system SHALL restore normal mouse interaction

### Requirement: Pin Window Context Menu
The system SHALL provide a context menu for pin window operations.

#### Scenario: Open context menu
- **WHEN** user right-clicks on a pin window
- **THEN** the system SHALL display a context menu with available actions

#### Scenario: Copy from context menu
- **WHEN** user selects "Copy" from the context menu
- **THEN** the system SHALL copy the pinned image to clipboard

#### Scenario: Save from context menu
- **WHEN** user selects "Save As..." from the context menu
- **THEN** the system SHALL open a save dialog for the pinned image

#### Scenario: Close pin window
- **WHEN** user selects "Close" from the context menu or presses Cmd+W
- **THEN** the system SHALL close the pin window

#### Scenario: Close all pin windows
- **WHEN** user selects "Close All Pins" from the context menu
- **THEN** the system SHALL close all open pin windows

### Requirement: Multi-Instance Pin Windows
The system SHALL support multiple simultaneous pin windows.

#### Scenario: Create multiple pins
- **WHEN** user pins multiple screenshots
- **THEN** the system SHALL create separate pin windows for each
- **AND** each window can be positioned independently

#### Scenario: Pin window management
- **WHEN** user has multiple pin windows open
- **THEN** the system SHALL track all windows
- **AND** provide "Close All" functionality

### Requirement: Pin Window Persistence
The system SHALL support optional persistence of pin windows across app restarts.

#### Scenario: Save pin state on quit
- **WHEN** user quits the application with pin windows open
- **AND** "Restore pins on launch" setting is enabled
- **THEN** the system SHALL save the state of all pin windows

#### Scenario: Restore pins on launch
- **WHEN** application launches with saved pin state
- **THEN** the system SHALL restore all previously open pin windows
- **AND** restore their positions and sizes

### Requirement: Pin Window on All Spaces
The system SHALL allow pin windows to appear on all virtual desktops.

#### Scenario: Show on all spaces
- **WHEN** user enables "Show on All Spaces" for a pin window
- **THEN** the system SHALL make the window visible on all macOS Spaces

#### Scenario: Show on current space only
- **WHEN** user disables "Show on All Spaces"
- **THEN** the system SHALL limit the window to the current Space
