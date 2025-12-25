## 1. Core Logic Port
- [x] 1.1 Create `StitchingService` in `PeekabooCore` based on `ScrollSnap/Managers/StitchingManager.swift`
- [x] 1.2 Implement `calculateOffset` using Vision framework
- [x] 1.3 Implement `composite` and `cropBottomRegion` image operations
- [x] 1.4 Write unit tests for image stitching with sample images

## 2. Capture Infrastructure
- [x] 2.1 Port `ScreenshotUtilities` to `PeekabooCore/Capture`
- [x] 2.2 Implement `ScreenCaptureKit` configuration for high-frequency capture
- [x] 2.3 Implement permission checks (Screen Recording)

## 3. Automation & Control
- [x] 3.1 Create `ScrollingCaptureEngine` to manage the capture loop
- [x] 3.2 Implement timer-based capture triggering (approx 0.25s interval)
- [x] 3.3 Add stop condition handling and final image generation
