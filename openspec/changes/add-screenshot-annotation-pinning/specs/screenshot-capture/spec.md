## ADDED Requirements

### Requirement: Interactive Area Selection
The system SHALL provide an interactive full-screen overlay for selecting capture regions.

#### Scenario: Start area selection
- **WHEN** user triggers area capture
- **THEN** the system SHALL display a semi-transparent overlay covering all screens
- **AND** the cursor changes to crosshair mode

#### Scenario: Drag to select region
- **WHEN** user clicks and drags on the overlay
- **THEN** the system SHALL highlight the selected rectangular region
- **AND** display the region dimensions (width × height) in real-time

#### Scenario: Cancel selection
- **WHEN** user presses ESC during selection
- **THEN** the system SHALL dismiss the overlay
- **AND** no capture is performed

#### Scenario: Complete selection
- **WHEN** user releases the mouse button after dragging
- **THEN** the system SHALL capture the selected region
- **AND** transition to annotation mode (if enabled) or complete the capture

### Requirement: Magnifier View
The system SHALL display a magnifier view during area selection for precise positioning.

#### Scenario: Show magnifier at cursor
- **WHEN** user moves the cursor during selection mode
- **THEN** the system SHALL display a magnified view of pixels around the cursor
- **AND** show the current pixel's color value (RGB/Hex)

#### Scenario: Toggle color format
- **WHEN** user presses Shift during selection
- **THEN** the system SHALL toggle between RGB and Hex color formats

#### Scenario: Copy color value
- **WHEN** user presses C during selection
- **THEN** the system SHALL copy the current pixel's color value to clipboard
- **AND** show a brief confirmation

### Requirement: Window Capture Mode
The system SHALL support capturing individual windows with visual highlighting.

#### Scenario: Highlight windows on hover
- **WHEN** user is in window capture mode
- **THEN** the system SHALL highlight the window under the cursor
- **AND** display the window title and application name

#### Scenario: Capture highlighted window
- **WHEN** user clicks on a highlighted window
- **THEN** the system SHALL capture only that window
- **AND** exclude desktop background and other windows

### Requirement: Multi-Display Support
The system SHALL support screenshot capture across multiple displays.

#### Scenario: Select region across displays
- **WHEN** user drags a selection across display boundaries
- **THEN** the system SHALL capture the combined region from all affected displays

#### Scenario: Capture specific display
- **WHEN** user triggers full-screen capture with multiple displays
- **THEN** the system SHALL capture the display where the cursor is located
