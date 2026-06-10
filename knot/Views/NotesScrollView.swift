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

        documentView = editableTextView
        hasVerticalScroller = true
        hasHorizontalScroller = false
        borderType = .noBorder
    }
}
