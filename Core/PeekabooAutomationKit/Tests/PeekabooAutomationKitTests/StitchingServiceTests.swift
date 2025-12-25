import XCTest
import AppKit
import Vision
@testable import PeekabooAutomationKit

final class StitchingServiceTests: XCTestCase {

    func testStitchingDownward() async throws {
        // Skip on CI if Vision is not available or reliable
        #if !canImport(Vision)
        throw XCTSkip("Vision framework not available")
        #endif

        let service = StitchingService()

        let width: CGFloat = 200
        let height: CGFloat = 400
        let size = NSSize(width: width, height: height)

        // Create a long virtual content image
        let contentHeight: CGFloat = 1000
        let contentImage = createPatternImage(size: NSSize(width: width, height: contentHeight))

        // Capture 1: Top of content (0 to 400)
        let rect1 = NSRect(x: 0, y: contentHeight - height, width: width, height: height)
        let image1 = crop(image: contentImage, to: rect1)

        // Capture 2: Scrolled down by 100 pixels (content moves up)
        // Viewport is now at (contentHeight - height - 100) to (contentHeight - 100)
        let rect2 = NSRect(x: 0, y: contentHeight - height - 100, width: width, height: height)
        let image2 = crop(image: contentImage, to: rect2)

        await service.startStitching(with: image1)
        await service.addImage(image2)

        let result = await service.stopStitching()
        XCTAssertNotNil(result)

        if let result = result {
            // Expected height: 400 (base) + 100 (new content) = 500
            // Allow for small margin of error in Vision detection
            XCTAssertEqual(result.size.height, 500, accuracy: 5)
            XCTAssertEqual(result.size.width, width)
        }
    }

    // Helpers

    func createPatternImage(size: NSSize) -> NSImage {
        return NSImage(size: size, flipped: false) { rect in
            NSColor.white.setFill()
            rect.fill()

            NSColor.black.setFill()
            let font = NSFont.systemFont(ofSize: 20)
            let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.black]

            // Draw horizontal lines every 50 pixels
            for y in stride(from: 0, to: size.height, by: 50) {
                let string = "Line at \(y)"
                string.draw(at: NSPoint(x: 10, y: CGFloat(y)), withAttributes: attrs)

                let path = NSBezierPath()
                path.move(to: NSPoint(x: 0, y: CGFloat(y)))
                path.line(to: NSPoint(x: size.width, y: CGFloat(y)))
                path.stroke()
            }
            return true
        }
    }

    func crop(image: NSImage, to rect: NSRect) -> NSImage {
        let newImage = NSImage(size: rect.size)
        newImage.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: rect.size),
                   from: rect,
                   operation: .copy,
                   fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }
}
