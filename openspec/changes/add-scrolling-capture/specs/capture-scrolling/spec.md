## ADDED Requirements
### Requirement: Scrolling Capture
The system SHALL support capturing multiple screenshots of a scrolling content area and stitching them into a single continuous image.

#### Scenario: Downward scrolling capture
- **WHEN** the user initiates scrolling capture on a scrollable region
- **AND** the user scrolls the content downwards
- **THEN** the system continuously captures frames
- **AND** stitches new content to the bottom of the composite image based on visual overlap

#### Scenario: Stop and save
- **WHEN** the user stops the capture session
- **THEN** the system produces a final stitched image
- **AND** saves it to the configured destination
