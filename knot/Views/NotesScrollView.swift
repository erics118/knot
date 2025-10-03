import Cocoa
import Defaults
import SwiftUI

final class NotesScrollView: NSScrollView {
    let editableTextView: EditableTextView

    override init(frame frameRect: NSRect) {
        self.editableTextView = EditableTextView(frame: frameRect)
        super.init(frame: frameRect)
        configure()
    }

    required init?(coder: NSCoder) {
        self.editableTextView = EditableTextView(frame: .zero)
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        autoresizingMask = [.width, .height]
        wantsLayer = true
        drawsBackground = false

        editableTextView.isRichText = false
        editableTextView.autoresizingMask = [.width, .height]
        editableTextView.font = NSFont.monospacedSystemFont(
            ofSize: 12,
            weight: .regular
        )
        editableTextView.drawsBackground = false
        editableTextView.isEditable = true
        editableTextView.isSelectable = true
        editableTextView.wantsLayer = true
        editableTextView.allowsUndo = true
        editableTextView.textContainerInset = NSSize(width: 20, height: 0)
        editableTextView.insertionPointColor = .green
        editableTextView.usesAdaptiveColorMappingForDarkAppearance = true

        documentView = editableTextView
        hasVerticalScroller = true
        hasHorizontalScroller = false
        borderType = .noBorder
    }
}
