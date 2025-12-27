//
//  DrawingTool.swift
//  Peekaboo
//
//  Created on 2025-12-26.
//

import AppKit
import SwiftUI

// MARK: - Tool Types

/// Available annotation tool types
enum AnnotationToolType: String, CaseIterable, Identifiable {
    case select
    case rectangle
    case ellipse
    case arrow
    case pen
    case text
    case mosaic

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .select: return "arrow.up.left.and.arrow.down.right"
        case .rectangle: return "rectangle"
        case .ellipse: return "circle"
        case .arrow: return "arrow.up.right"
        case .pen: return "pencil.tip"
        case .text: return "textformat"
        case .mosaic: return "square.grid.3x3"
        }
    }

    var displayName: String {
        switch self {
        case .select: return "Select"
        case .rectangle: return "Rectangle"
        case .ellipse: return "Ellipse"
        case .arrow: return "Arrow"
        case .pen: return "Pen"
        case .text: return "Text"
        case .mosaic: return "Mosaic"
        }
    }
}

// MARK: - Annotation Element

/// Base protocol for all annotation elements
@MainActor
protocol AnnotationElement {
    var id: UUID { get }
    var bounds: CGRect { get }

    func draw(in context: GraphicsContext)
    func hitTest(point: CGPoint) -> Bool
}

// MARK: - Shape Annotation

/// A shape annotation (rectangle, ellipse, arrow)
@MainActor
struct ShapeAnnotation: AnnotationElement {
    let id: UUID
    var shapeType: AnnotationToolType
    var startPoint: CGPoint
    var endPoint: CGPoint
    var strokeColor: Color
    var strokeWidth: CGFloat
    var isFilled: Bool

    var bounds: CGRect {
        CGRect(
            x: min(self.startPoint.x, self.endPoint.x),
            y: min(self.startPoint.y, self.endPoint.y),
            width: abs(self.endPoint.x - self.startPoint.x),
            height: abs(self.endPoint.y - self.startPoint.y)
        )
    }

    init(
        id: UUID = UUID(),
        shapeType: AnnotationToolType,
        startPoint: CGPoint,
        endPoint: CGPoint,
        strokeColor: Color,
        strokeWidth: CGFloat,
        isFilled: Bool = false
    ) {
        self.id = id
        self.shapeType = shapeType
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.isFilled = isFilled
    }

    func draw(in context: GraphicsContext) {
        switch self.shapeType {
        case .rectangle:
            self.drawRectangle(in: context)
        case .ellipse:
            self.drawEllipse(in: context)
        case .arrow:
            self.drawArrow(in: context)
        default:
            break
        }
    }

    private func drawRectangle(in context: GraphicsContext) {
        let rect = self.bounds
        if self.isFilled {
            context.fill(Path(roundedRect: rect, cornerRadius: 0), with: .color(self.strokeColor))
        } else {
            context.stroke(
                Path(roundedRect: rect, cornerRadius: 0),
                with: .color(self.strokeColor),
                lineWidth: self.strokeWidth
            )
        }
    }

    private func drawEllipse(in context: GraphicsContext) {
        let rect = self.bounds
        if self.isFilled {
            context.fill(Path(ellipseIn: rect), with: .color(self.strokeColor))
        } else {
            context.stroke(
                Path(ellipseIn: rect),
                with: .color(self.strokeColor),
                lineWidth: self.strokeWidth
            )
        }
    }

    private func drawArrow(in context: GraphicsContext) {
        let path = Self.arrowPath(from: self.startPoint, to: self.endPoint, lineWidth: self.strokeWidth)
        context.fill(path, with: .color(self.strokeColor))
    }

    /// Creates an arrow path from start to end point
    static func arrowPath(from start: CGPoint, to end: CGPoint, lineWidth: CGFloat) -> Path {
        var path = Path()

        let dx = end.x - start.x
        let dy = end.y - start.y
        let length = sqrt(dx * dx + dy * dy)

        guard length > 0 else { return path }

        // Normalize direction
        let nx = dx / length
        let ny = dy / length

        // Perpendicular direction
        let px = -ny
        let py = nx

        // Arrow dimensions based on line width
        let headLength = max(lineWidth * 4, 15)
        let headWidth = max(lineWidth * 2.5, 10)
        let bodyWidth = lineWidth

        // Arrow head base point
        let headBase = CGPoint(
            x: end.x - nx * headLength,
            y: end.y - ny * headLength
        )

        // Build arrow shape
        // Start from bottom-left of body
        path.move(to: CGPoint(
            x: start.x + px * bodyWidth / 2,
            y: start.y + py * bodyWidth / 2
        ))

        // Bottom-right of body
        path.addLine(to: CGPoint(
            x: start.x - px * bodyWidth / 2,
            y: start.y - py * bodyWidth / 2
        ))

        // To head base (right side)
        path.addLine(to: CGPoint(
            x: headBase.x - px * bodyWidth / 2,
            y: headBase.y - py * bodyWidth / 2
        ))

        // Right wing of arrow head
        path.addLine(to: CGPoint(
            x: headBase.x - px * headWidth,
            y: headBase.y - py * headWidth
        ))

        // Tip of arrow
        path.addLine(to: end)

        // Left wing of arrow head
        path.addLine(to: CGPoint(
            x: headBase.x + px * headWidth,
            y: headBase.y + py * headWidth
        ))

        // Back to head base (left side)
        path.addLine(to: CGPoint(
            x: headBase.x + px * bodyWidth / 2,
            y: headBase.y + py * bodyWidth / 2
        ))

        path.closeSubpath()

        return path
    }

    func hitTest(point: CGPoint) -> Bool {
        self.bounds.insetBy(dx: -5, dy: -5).contains(point)
    }
}

// MARK: - Path Annotation (Pen/Freehand)

/// A freehand path annotation
@MainActor
struct PathAnnotation: AnnotationElement {
    let id: UUID
    var points: [CGPoint]
    var strokeColor: Color
    var strokeWidth: CGFloat

    var bounds: CGRect {
        guard !self.points.isEmpty else { return .zero }
        let xs = self.points.map(\.x)
        let ys = self.points.map(\.y)
        return CGRect(
            x: xs.min()!,
            y: ys.min()!,
            width: xs.max()! - xs.min()!,
            height: ys.max()! - ys.min()!
        )
    }

    init(
        id: UUID = UUID(),
        points: [CGPoint],
        strokeColor: Color,
        strokeWidth: CGFloat
    ) {
        self.id = id
        self.points = points
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
    }

    func draw(in context: GraphicsContext) {
        guard self.points.count >= 2 else { return }

        var path = Path()
        path.move(to: self.points[0])

        for point in self.points.dropFirst() {
            path.addLine(to: point)
        }

        context.stroke(
            path,
            with: .color(self.strokeColor),
            style: StrokeStyle(lineWidth: self.strokeWidth, lineCap: .round, lineJoin: .round)
        )
    }

    func hitTest(point: CGPoint) -> Bool {
        for p in self.points {
            if hypot(p.x - point.x, p.y - point.y) < self.strokeWidth + 5 {
                return true
            }
        }
        return false
    }
}

// MARK: - Text Annotation

/// A text annotation
@MainActor
struct TextAnnotation: AnnotationElement {
    let id: UUID
    var position: CGPoint
    var text: String
    var fontSize: CGFloat
    var textColor: Color

    var bounds: CGRect {
        // Approximate bounds based on text length
        let width = CGFloat(self.text.count) * self.fontSize * 0.6
        let height = self.fontSize * 1.5
        return CGRect(x: self.position.x, y: self.position.y, width: width, height: height)
    }

    init(
        id: UUID = UUID(),
        position: CGPoint,
        text: String,
        fontSize: CGFloat,
        textColor: Color
    ) {
        self.id = id
        self.position = position
        self.text = text
        self.fontSize = fontSize
        self.textColor = textColor
    }

    func draw(in context: GraphicsContext) {
        context.draw(
            Text(self.text)
                .font(.system(size: self.fontSize, weight: .medium))
                .foregroundColor(self.textColor),
            at: self.position,
            anchor: .topLeading
        )
    }

    func hitTest(point: CGPoint) -> Bool {
        self.bounds.insetBy(dx: -5, dy: -5).contains(point)
    }
}

// MARK: - Mosaic Annotation

/// A mosaic/pixelate annotation for a rectangular region
@MainActor
struct MosaicAnnotation: AnnotationElement {
    let id: UUID
    var region: CGRect
    var pixelSize: Int

    var bounds: CGRect { self.region }

    init(id: UUID = UUID(), region: CGRect, pixelSize: Int = 10) {
        self.id = id
        self.region = region
        self.pixelSize = pixelSize
    }

    func draw(in context: GraphicsContext) {
        // Draw a grid pattern to indicate mosaic area
        // Actual pixelation is applied when rendering the final image
        context.stroke(
            Path(self.region),
            with: .color(.gray.opacity(0.5)),
            style: StrokeStyle(lineWidth: 2, dash: [5, 5])
        )

        // Draw grid lines to indicate pixelation
        let gridSize = CGFloat(self.pixelSize)
        var gridPath = Path()

        var x = self.region.minX
        while x <= self.region.maxX {
            gridPath.move(to: CGPoint(x: x, y: self.region.minY))
            gridPath.addLine(to: CGPoint(x: x, y: self.region.maxY))
            x += gridSize
        }

        var y = self.region.minY
        while y <= self.region.maxY {
            gridPath.move(to: CGPoint(x: self.region.minX, y: y))
            gridPath.addLine(to: CGPoint(x: self.region.maxX, y: y))
            y += gridSize
        }

        context.stroke(gridPath, with: .color(.gray.opacity(0.3)), lineWidth: 0.5)
    }

    func hitTest(point: CGPoint) -> Bool {
        self.region.contains(point)
    }
}

// MARK: - Any Annotation Wrapper

/// Type-erased wrapper for any annotation element
@MainActor
struct AnyAnnotation: AnnotationElement {
    let id: UUID
    private let _bounds: () -> CGRect
    private let _draw: (GraphicsContext) -> Void
    private let _hitTest: (CGPoint) -> Bool

    var bounds: CGRect { self._bounds() }

    init<A: AnnotationElement>(_ annotation: A) {
        self.id = annotation.id
        self._bounds = { annotation.bounds }
        self._draw = { context in annotation.draw(in: context) }
        self._hitTest = { annotation.hitTest(point: $0) }
    }

    func draw(in context: GraphicsContext) {
        self._draw(context)
    }

    func hitTest(point: CGPoint) -> Bool {
        self._hitTest(point)
    }
}
