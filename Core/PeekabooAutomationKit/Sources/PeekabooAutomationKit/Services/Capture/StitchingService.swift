import AppKit
import Vision

public actor StitchingService {
    private var runningStitchedImage: NSImage?
    private var previousImage: NSImage?

    public init() {}

    public func startStitching(with initialImage: NSImage) {
        runningStitchedImage = initialImage
        previousImage = initialImage
    }

    public func addImage(_ image: NSImage) {
        guard let baseStitchedImage = runningStitchedImage,
              let prevImage = previousImage else {
            runningStitchedImage = image
            previousImage = image
            return
        }

        guard let offset = calculateOffset(from: image, to: prevImage) else {
            previousImage = image
            return
        }

        if offset > 0 {
            // Downward scroll
            if let newStitched = composite(baseImage: baseStitchedImage, newImage: image, offset: offset) {
                runningStitchedImage = newStitched
                previousImage = image
            }
        } else if offset < 0 {
            // Upward scroll
            let cropAmount = abs(offset)
            if cropAmount <= baseStitchedImage.size.height,
               let cropped = cropBottomRegion(of: baseStitchedImage, byAmount: cropAmount) {
                runningStitchedImage = cropped
                previousImage = image
            }
        } else {
            previousImage = image
        }
    }

    public func stopStitching() -> NSImage? {
        return runningStitchedImage
    }

    private func calculateOffset(from currentImage: NSImage, to previousImage: NSImage) -> CGFloat? {
        guard let currentCG = currentImage.cgImage(forProposedRect: nil, context: nil, hints: nil),
              let previousCG = previousImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }

        guard let verticalOffsetInPixels = findVerticalOffset(from: currentCG, to: previousCG) else {
            return nil
        }

        guard currentImage.size.height > 0 else { return nil }
        let scale = CGFloat(currentCG.height) / currentImage.size.height
        return verticalOffsetInPixels / (scale > 0 ? scale : 1.0)
    }

    private func findVerticalOffset(from image1: CGImage, to image2: CGImage) -> CGFloat? {
        let request = VNTranslationalImageRegistrationRequest(targetedCGImage: image2)
        let handler = VNImageRequestHandler(cgImage: image1, options: [:])

        do {
            try handler.perform([request])
        } catch {
            return nil
        }

        guard let observation = request.results?.first as? VNImageTranslationAlignmentObservation else {
            return nil
        }

        return observation.alignmentTransform.ty
    }

    private func composite(baseImage: NSImage, newImage: NSImage, offset: CGFloat) -> NSImage? {
        let baseSize = baseImage.size
        let newSize = newImage.size
        let totalHeight = baseSize.height + offset
        let outputSize = NSSize(width: baseSize.width, height: totalHeight)

        return NSImage(size: outputSize, flipped: false) { dstRect in
             // 1. Draw base image at top
             // Coordinate system is bottom-left (flipped=false)
             // Top of canvas is at y = totalHeight
             // Base image has height baseSize.height
             // So base image origin y should be totalHeight - baseSize.height

             let baseRect = NSRect(x: 0, y: totalHeight - baseSize.height, width: baseSize.width, height: baseSize.height)
             baseImage.draw(in: baseRect)

             // 2. Draw new image at bottom
             let newRect = NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
             newImage.draw(in: newRect)

             return true
        }
    }

    private func cropBottomRegion(of image: NSImage, byAmount amount: CGFloat) -> NSImage? {
        let originalSize = image.size
        guard amount > 0, amount < originalSize.height else { return image }

        let newHeight = originalSize.height - amount
        let newSize = NSSize(width: originalSize.width, height: newHeight)

        return NSImage(size: newSize, flipped: false) { dstRect in
            // Keep top content, crop from bottom.
            // In bottom-up coords:
            // We want the pixels from y=amount to y=originalHeight
            // And draw them into y=0 to y=newHeight

            let sourceRect = NSRect(x: 0, y: amount, width: originalSize.width, height: newHeight)
            let destRect = NSRect(origin: .zero, size: newSize)

            image.draw(in: destRect, from: sourceRect, operation: .copy, fraction: 1.0)
            return true
        }
    }
}
