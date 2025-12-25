import AppKit
import Foundation
import CoreGraphics

public actor ScrollingCaptureEngine {
    private let captureService: ScreenCaptureService
    private let stitchingService: StitchingService
    private var isCapturing = false
    private var captureTask: Task<Void, Never>?
    private var rectangle: CGRect = .zero

    public init(captureService: ScreenCaptureService) {
        self.captureService = captureService
        self.stitchingService = StitchingService()
    }

    public func startCapture(rect: CGRect) async {
        guard !isCapturing else { return }
        isCapturing = true
        rectangle = rect

        // Initial capture
        do {
            let cgImage = try await captureService.captureRegionImage(rect)
            let nsImage = NSImage(cgImage: cgImage, size: rect.size)
            await stitchingService.startStitching(with: nsImage)
        } catch {
            print("Failed to start scrolling capture: \(error)")
            isCapturing = false
            return
        }

        // Start timer loop
        captureTask = Task { [weak self] in
            while !Task.isCancelled {
                // Wait 0.25s
                try? await Task.sleep(nanoseconds: 250_000_000)
                guard let self = self else { return }

                let stillActive = await self.isActive
                guard stillActive else { break }

                await self.performCapture()
            }
        }
    }

    private func performCapture() async {
        guard isCapturing else { return }
        do {
            let cgImage = try await captureService.captureRegionImage(rectangle)
            let nsImage = NSImage(cgImage: cgImage, size: rectangle.size)
            await stitchingService.addImage(nsImage)
        } catch {
            print("Scrolling capture frame failed: \(error)")
        }
    }

    public func stopCapture() async -> NSImage? {
        isCapturing = false
        captureTask?.cancel()
        _ = await captureTask?.result // Wait for task to finish
        captureTask = nil
        return await stitchingService.stopStitching()
    }

    public var isActive: Bool {
        isCapturing
    }
}
