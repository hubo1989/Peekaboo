//
//  AnnotationToolbar.swift
//  Peekaboo
//
//  Created on 2025-12-26.
//

import SwiftUI

/// Floating toolbar for annotation tools
struct AnnotationToolbar: View {
    @Bindable var manager: AnnotationManager

    let onCopy: () -> Void
    let onSave: () -> Void
    let onPin: () -> Void
    let onSendToAI: () -> Void
    let onCancel: () -> Void

    @State private var showColorPicker = false
    @State private var showStrokeWidthPicker = false

    var body: some View {
        HStack(spacing: 0) {
            // Drawing tools
            self.toolsSection

            self.divider

            // Color picker
            self.colorSection

            self.divider

            // Stroke width
            self.strokeWidthSection

            self.divider

            // Undo/Redo
            self.undoRedoSection

            self.divider

            // Action buttons
            self.actionsSection
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(self.toolbarBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }

    // MARK: - Tools Section

    private var toolsSection: some View {
        HStack(spacing: 4) {
            ForEach(AnnotationToolType.allCases.filter { $0 != .select }) { tool in
                self.toolButton(for: tool)
            }
        }
    }

    private func toolButton(for tool: AnnotationToolType) -> some View {
        Button {
            self.manager.currentTool = tool
        } label: {
            Image(systemName: tool.icon)
                .font(.system(size: 14, weight: .medium))
                .frame(width: 28, height: 28)
                .background(
                    self.manager.currentTool == tool
                        ? Color.accentColor.opacity(0.3)
                        : Color.clear
                )
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .help(tool.displayName)
    }

    // MARK: - Color Section

    private var colorSection: some View {
        HStack(spacing: 4) {
            // Current color indicator
            Button {
                self.showColorPicker.toggle()
            } label: {
                Circle()
                    .fill(self.manager.strokeColor)
                    .frame(width: 20, height: 20)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(color: .black.opacity(0.2), radius: 2)
            }
            .buttonStyle(.plain)
            .popover(isPresented: self.$showColorPicker) {
                self.colorPickerPopover
            }
        }
    }

    private var colorPickerPopover: some View {
        VStack(spacing: 8) {
            Text("Color")
                .font(.caption)
                .foregroundColor(.secondary)

            LazyVGrid(columns: Array(repeating: GridItem(.fixed(28)), count: 5), spacing: 6) {
                ForEach(AnnotationManager.availableColors, id: \.self) { color in
                    Button {
                        self.manager.strokeColor = color
                        self.showColorPicker = false
                    } label: {
                        Circle()
                            .fill(color)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .stroke(
                                        self.manager.strokeColor == color
                                            ? Color.accentColor
                                            : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            ColorPicker("Custom", selection: self.$manager.strokeColor)
                .labelsHidden()
        }
        .padding()
        .frame(width: 180)
    }

    // MARK: - Stroke Width Section

    private var strokeWidthSection: some View {
        Button {
            self.showStrokeWidthPicker.toggle()
        } label: {
            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.primary)
                    .frame(width: 16, height: self.manager.strokeWidth)
                Image(systemName: "chevron.down")
                    .font(.system(size: 8))
            }
            .frame(width: 36, height: 28)
        }
        .buttonStyle(.plain)
        .popover(isPresented: self.$showStrokeWidthPicker) {
            self.strokeWidthPopover
        }
    }

    private var strokeWidthPopover: some View {
        VStack(spacing: 8) {
            Text("Stroke Width")
                .font(.caption)
                .foregroundColor(.secondary)

            ForEach(AnnotationManager.availableStrokeWidths, id: \.self) { width in
                Button {
                    self.manager.strokeWidth = width
                    self.showStrokeWidthPicker = false
                } label: {
                    HStack {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color.primary)
                            .frame(width: 40, height: width)

                        Text("\(Int(width))px")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        if self.manager.strokeWidth == width {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .frame(width: 140)
    }

    // MARK: - Undo/Redo Section

    private var undoRedoSection: some View {
        HStack(spacing: 4) {
            Button {
                self.manager.undo()
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 14))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .disabled(!self.manager.canUndo)
            .opacity(self.manager.canUndo ? 1 : 0.4)
            .help("Undo (⌘Z)")

            Button {
                self.manager.redo()
            } label: {
                Image(systemName: "arrow.uturn.forward")
                    .font(.system(size: 14))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .disabled(!self.manager.canRedo)
            .opacity(self.manager.canRedo ? 1 : 0.4)
            .help("Redo (⌘⇧Z)")
        }
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        HStack(spacing: 6) {
            // Cancel
            Button {
                self.onCancel()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 26, height: 26)
                    .background(Color.gray.opacity(0.6))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .help("Cancel (ESC)")

            // Copy
            Button {
                self.onCopy()
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 26, height: 26)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .help("Copy to Clipboard (⌘C)")

            // Save
            Button {
                self.onSave()
            } label: {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 26, height: 26)
                    .background(Color.green)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .help("Save to File (⌘S)")

            // Pin
            Button {
                self.onPin()
            } label: {
                Image(systemName: "pin")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 26, height: 26)
                    .background(Color.orange)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .help("Pin to Desktop")

            // Send to AI
            Button {
                self.onSendToAI()
            } label: {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 26, height: 26)
                    .background(Color.purple)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .help("Send to AI")
        }
    }

    // MARK: - Helper Views

    private var divider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 1, height: 24)
            .padding(.horizontal, 8)
    }

    private var toolbarBackground: some View {
        VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
    }
}

#Preview {
    AnnotationToolbar(
        manager: AnnotationManager(),
        onCopy: { },
        onSave: { },
        onPin: { },
        onSendToAI: { },
        onCancel: { }
    )
    .padding()
    .background(Color.gray.opacity(0.3))
}
