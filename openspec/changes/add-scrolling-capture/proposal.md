# Change: Add Scrolling Capture

## Why
Users frequently need to capture content that exceeds the visible screen area, such as long web pages or document feeds. Current single-screen capture tools are insufficient for these use cases. Porting the proven scrolling capture logic from `ScrollSnap` will enable `Peekaboo` to handle these scenarios natively.

## What Changes
- Port `StitchingManager` logic (Vision-based alignment) to `PeekabooCore`.
- Port `ScreenshotUtilities` (ScreenCaptureKit integration) to support rapid sequential capture.
- Introduce `capture-scrolling` capability to the spec.
- Implement the capture loop (scroll -> capture -> stitch).

## Impact
- **Specs**: Adds `specs/capture-scrolling`.
- **Code**: Adds new modules to `Core/PeekabooCore` (e.g., `Stitching`, `ScrollingCapture`).
- **Dependencies**: Requires `Vision` and `ScreenCaptureKit` frameworks.
