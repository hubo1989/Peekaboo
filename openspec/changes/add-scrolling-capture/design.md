## Context
We are porting functionality from `ScrollSnap` to `Peekaboo`. The core challenge is real-time image alignment and stitching using the `Vision` framework.

## Decisions
- **Framework**: Use `Vision` (`VNTranslationalImageRegistrationRequest`) for offset calculation, as it's robust against minor rendering differences.
- **Capture Method**: Use `ScreenCaptureKit` for high-performance, low-latency captures.
- **Architecture**:
    - `StitchingService`: Pure logic for image processing.
    - `CaptureSession`: Stateful manager for the active capture loop.
    - Logic placed in `PeekabooCore` to be shared between CLI and Mac app.

## Risks / Trade-offs
- **Memory Usage**: Storing full-resolution bitmaps in memory during long captures can be heavy.
    - *Mitigation*: We may need to periodically flush to disk or compress, but for V1 we'll stick to in-memory `NSImage` as per `ScrollSnap` implementation.
- **Scroll Speed**: If the user scrolls faster than the capture rate (approx 4fps), gaps may appear.
    - *Mitigation*: The UI should encourage moderate scroll speeds.
