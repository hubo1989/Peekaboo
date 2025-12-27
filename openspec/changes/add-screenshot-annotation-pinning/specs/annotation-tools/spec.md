## ADDED Requirements

### Requirement: Annotation Toolbar
The system SHALL provide a floating toolbar with annotation tools after capturing a screenshot.

#### Scenario: Show toolbar after capture
- **WHEN** user completes a region selection
- **THEN** the system SHALL display an annotation toolbar near the selected region
- **AND** the toolbar contains drawing tool buttons

#### Scenario: Toolbar tool selection
- **WHEN** user clicks a tool button in the toolbar
- **THEN** the system SHALL activate that tool
- **AND** highlight the selected tool button

### Requirement: Rectangle Drawing Tool
The system SHALL provide a rectangle drawing tool for annotations.

#### Scenario: Draw rectangle
- **WHEN** user selects the rectangle tool and drags on the canvas
- **THEN** the system SHALL draw a rectangle from the start to end point
- **AND** use the current color and stroke width settings

#### Scenario: Rectangle with fill
- **WHEN** user holds Shift while drawing a rectangle
- **THEN** the system SHALL draw a filled rectangle instead of outlined

### Requirement: Ellipse Drawing Tool
The system SHALL provide an ellipse drawing tool for annotations.

#### Scenario: Draw ellipse
- **WHEN** user selects the ellipse tool and drags on the canvas
- **THEN** the system SHALL draw an ellipse bounded by the drag rectangle
- **AND** use the current color and stroke width settings

#### Scenario: Draw circle
- **WHEN** user holds Shift while drawing an ellipse
- **THEN** the system SHALL constrain the shape to a perfect circle

### Requirement: Arrow Drawing Tool
The system SHALL provide an arrow drawing tool for pointing to specific areas.

#### Scenario: Draw arrow
- **WHEN** user selects the arrow tool and drags on the canvas
- **THEN** the system SHALL draw an arrow from start to end point
- **AND** the arrowhead points in the drag direction

### Requirement: Freehand Drawing Tool
The system SHALL provide a pen/brush tool for freehand drawing.

#### Scenario: Freehand drawing
- **WHEN** user selects the pen tool and draws on the canvas
- **THEN** the system SHALL render a smooth path following the cursor movement
- **AND** use the current color and stroke width settings

### Requirement: Text Annotation Tool
The system SHALL provide a text tool for adding text annotations.

#### Scenario: Add text annotation
- **WHEN** user selects the text tool and clicks on the canvas
- **THEN** the system SHALL display a text input field at that location
- **AND** user can type text content

#### Scenario: Complete text input
- **WHEN** user presses Enter or clicks outside the text field
- **THEN** the system SHALL render the text as an annotation
- **AND** the text uses the current color and font size settings

### Requirement: Mosaic/Blur Tool
The system SHALL provide a mosaic or blur tool for obscuring sensitive information.

#### Scenario: Apply mosaic
- **WHEN** user selects the mosaic tool and drags over an area
- **THEN** the system SHALL pixelate the covered region
- **AND** maintain the mosaic when saving the image

### Requirement: Color Picker
The system SHALL provide a color picker for selecting annotation colors.

#### Scenario: Select color from palette
- **WHEN** user clicks the color picker in the toolbar
- **THEN** the system SHALL display a color selection palette
- **AND** user can select a color for subsequent annotations

#### Scenario: Custom color input
- **WHEN** user enters a hex color value
- **THEN** the system SHALL apply that color to the picker
- **AND** use it for subsequent annotations

### Requirement: Stroke Width Control
The system SHALL allow users to adjust the stroke width for drawing tools.

#### Scenario: Adjust stroke width
- **WHEN** user adjusts the stroke width slider in the toolbar
- **THEN** the system SHALL update the stroke width for subsequent drawings
- **AND** display a preview of the selected width

### Requirement: Undo/Redo Support
The system SHALL support undoing and redoing annotation actions.

#### Scenario: Undo last action
- **WHEN** user presses Cmd+Z or clicks the undo button
- **THEN** the system SHALL remove the last annotation
- **AND** add it to the redo stack

#### Scenario: Redo action
- **WHEN** user presses Cmd+Shift+Z or clicks the redo button
- **THEN** the system SHALL restore the last undone annotation

### Requirement: Screenshot Output Actions
The system SHALL provide actions for handling the annotated screenshot.

#### Scenario: Copy to clipboard
- **WHEN** user clicks the "Copy" button or presses Cmd+C
- **THEN** the system SHALL copy the annotated screenshot to the system clipboard

#### Scenario: Save to file
- **WHEN** user clicks the "Save" button or presses Cmd+S
- **THEN** the system SHALL save the annotated screenshot to the default location
- **AND** use the configured image format (PNG/JPEG)

#### Scenario: Send to AI
- **WHEN** user clicks the "Send to AI" button
- **THEN** the system SHALL create a new AI session with the screenshot attached
- **AND** open the AI chat window

#### Scenario: Pin to desktop
- **WHEN** user clicks the "Pin" button
- **THEN** the system SHALL create a floating pin window with the screenshot
