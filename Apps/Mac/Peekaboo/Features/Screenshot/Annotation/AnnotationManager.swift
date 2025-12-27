//
//  AnnotationManager.swift
//  Peekaboo
//
//  Created on 2025-12-26.
//

import Observation
import SwiftUI

/// Manages annotation state including current tool, elements, and undo/redo history
@Observable
@MainActor
final class AnnotationManager {
    // MARK: - Properties

    /// Current selected tool
    var currentTool: AnnotationToolType = .rectangle

    /// Current stroke color
    var strokeColor: Color = .red

    /// Current stroke width
    var strokeWidth: CGFloat = 3.0

    /// Current font size for text tool
    var fontSize: CGFloat = 16.0

    /// All annotation elements
    private(set) var elements: [AnyAnnotation] = []

    /// Undo stack
    private var undoStack: [[AnyAnnotation]] = []

    /// Redo stack
    private var redoStack: [[AnyAnnotation]] = []

    /// Currently drawing element (while dragging)
    var currentDrawing: AnyAnnotation?

    /// Starting point of the current drawing operation
    private var drawingStartPoint: CGPoint?

    /// Whether we're in text editing mode
    var isEditingText: Bool = false

    /// Text input position
    var textInputPosition: CGPoint?

    /// Text input content
    var textInputContent: String = ""

    // MARK: - Computed Properties

    var canUndo: Bool { !self.undoStack.isEmpty }
    var canRedo: Bool { !self.redoStack.isEmpty }

    // MARK: - Available Colors

    static let availableColors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink, .white, .black
    ]

    // MARK: - Available Stroke Widths

    static let availableStrokeWidths: [CGFloat] = [1, 2, 3, 5, 8, 12]

    // MARK: - Element Management

    /// Add an annotation element
    func addElement(_ element: some AnnotationElement) {
        self.saveStateForUndo()
        self.elements.append(AnyAnnotation(element))
        self.redoStack.removeAll()
    }

    /// Remove an annotation element by ID
    func removeElement(id: UUID) {
        self.saveStateForUndo()
        self.elements.removeAll { $0.id == id }
        self.redoStack.removeAll()
    }

    /// Clear all elements
    func clearAll() {
        guard !self.elements.isEmpty else { return }
        self.saveStateForUndo()
        self.elements.removeAll()
        self.redoStack.removeAll()
    }

    // MARK: - Drawing Operations

    /// Start drawing a new element
    func startDrawing(at point: CGPoint, shiftHeld: Bool = false) {
        self.drawingStartPoint = point

        switch self.currentTool {
        case .rectangle, .ellipse, .arrow:
            let shape = ShapeAnnotation(
                shapeType: self.currentTool,
                startPoint: point,
                endPoint: point,
                strokeColor: self.strokeColor,
                strokeWidth: self.strokeWidth,
                isFilled: shiftHeld
            )
            self.currentDrawing = AnyAnnotation(shape)

        case .pen:
            let path = PathAnnotation(
                points: [point],
                strokeColor: self.strokeColor,
                strokeWidth: self.strokeWidth
            )
            self.currentDrawing = AnyAnnotation(path)

        case .mosaic:
            let mosaic = MosaicAnnotation(
                region: CGRect(origin: point, size: .zero),
                pixelSize: 10
            )
            self.currentDrawing = AnyAnnotation(mosaic)

        case .text:
            self.textInputPosition = point
            self.textInputContent = ""
            self.isEditingText = true

        case .select:
            break
        }
    }

    /// Continue drawing (drag)
    func continueDrawing(to point: CGPoint, shiftHeld: Bool = false) {
        guard self.currentDrawing != nil, let startPoint = self.drawingStartPoint else { return }

        switch self.currentTool {
        case .rectangle, .ellipse, .arrow:
            let shape = ShapeAnnotation(
                id: self.currentDrawing!.id,
                shapeType: self.currentTool,
                startPoint: startPoint,
                endPoint: point,
                strokeColor: self.strokeColor,
                strokeWidth: self.strokeWidth,
                isFilled: shiftHeld
            )
            self.currentDrawing = AnyAnnotation(shape)

        case .pen:
            var points = self.getCurrentPoints() ?? []
            points.append(point)
            let path = PathAnnotation(
                id: self.currentDrawing!.id,
                points: points,
                strokeColor: self.strokeColor,
                strokeWidth: self.strokeWidth
            )
            self.currentDrawing = AnyAnnotation(path)

        case .mosaic:
            let region = CGRect(
                x: min(startPoint.x, point.x),
                y: min(startPoint.y, point.y),
                width: abs(point.x - startPoint.x),
                height: abs(point.y - startPoint.y)
            )
            let mosaic = MosaicAnnotation(
                id: self.currentDrawing!.id,
                region: region
            )
            self.currentDrawing = AnyAnnotation(mosaic)

        default:
            break
        }
    }

    /// Finish drawing
    func finishDrawing() {
        self.drawingStartPoint = nil
        guard let drawing = self.currentDrawing else { return }

        // Only add if the element has meaningful size
        if drawing.bounds.width > 2 || drawing.bounds.height > 2 {
            self.saveStateForUndo()
            self.elements.append(drawing)
            self.redoStack.removeAll()
        }

        self.currentDrawing = nil
    }

    /// Complete text input
    func completeTextInput() {
        guard self.isEditingText,
              let position = self.textInputPosition,
              !self.textInputContent.isEmpty else {
            self.cancelTextInput()
            return
        }

        let textAnnotation = TextAnnotation(
            position: position,
            text: self.textInputContent,
            fontSize: self.fontSize,
            textColor: self.strokeColor
        )

        self.addElement(textAnnotation)
        self.cancelTextInput()
    }

    /// Cancel text input
    func cancelTextInput() {
        self.isEditingText = false
        self.textInputPosition = nil
        self.textInputContent = ""
    }

    // MARK: - Undo/Redo

    /// Undo the last action
    func undo() {
        guard self.canUndo else { return }
        self.redoStack.append(self.elements)
        self.elements = self.undoStack.removeLast()
    }

    /// Redo the last undone action
    func redo() {
        guard self.canRedo else { return }
        self.undoStack.append(self.elements)
        self.elements = self.redoStack.removeLast()
    }

    // MARK: - Private Helpers

    private func saveStateForUndo() {
        self.undoStack.append(self.elements)
        // Limit undo history
        if self.undoStack.count > 50 {
            self.undoStack.removeFirst()
        }
    }

    private func getStartPoint() -> CGPoint? {
        // This is a simplified approach - in a full implementation,
        // we'd need to store the original shape data
        self.currentDrawing?.bounds.origin
    }

    private func getCurrentPoints() -> [CGPoint]? {
        // For pen tool, we need to track points separately
        // This is handled by the PathAnnotation creation
        nil
    }
}

// MARK: - Annotation State for Rendering

extension AnnotationManager {
    /// Get all elements to render (including current drawing)
    var renderableElements: [AnyAnnotation] {
        var result = self.elements
        if let current = self.currentDrawing {
            result.append(current)
        }
        return result
    }
}
