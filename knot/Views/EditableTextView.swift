import Cocoa
import Defaults

class EditableTextView: NSTextView {
    override func didChangeText() {
        super.didChangeText()

        applyHeadingBoldStyling()
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        // Apply styling when the view is first displayed
        if window != nil && !string.isEmpty {
            applyHeadingBoldStyling()
        }
    }

    override var string: String {
        didSet {
            // Apply styling when text is set programmatically
            if !string.isEmpty {
                applyHeadingBoldStyling()
            }
        }
    }

    func applyHeadingBoldStyling() {
        guard let textStorage = self.textStorage else { return }

        let selection = self.selectedRanges

        textStorage.beginEditing()
        defer {
            textStorage.endEditing()
            self.selectedRanges = selection
        }

        // reset everything to default font
        textStorage.addAttribute(
            .font,
            value: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular),
            range: NSRange(location: 0, length: textStorage.length)
        )

        let boldFont = NSFont.monospacedSystemFont(ofSize: 12, weight: .bold)

        let str = textStorage.string

        // for each substring (ie, each line), check
        textStorage.string.enumerateSubstrings(
            in: str.startIndex..<str.endIndex,
            options: [.byLines]
        ) { _, substringRange, _, _ in
            guard !substringRange.isEmpty else { return }

            // check the first char of this line
            guard str[substringRange].first == "#" else { return }

            // add the bold attribute
            textStorage.addAttribute(
                .font,
                value: boldFont,
                range: NSRange(substringRange, in: textStorage.string)
            )
        }
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let modifierFlags = event.modifierFlags.intersection(
            .deviceIndependentFlagsMask
        )

        // Helpers
        func switchNote(_ idx: Int) {
            guard let win = window as? NotesWindow else { return }
            win.switchToNote(idx)
        }
        func prevNote() {
            let i = Defaults[.currentNoteIndex]
            switchNote((i - 1 + 5) % 5)
        }
        func nextNote() {
            let i = Defaults[.currentNoteIndex]
            switchNote((i + 1) % 5)
        }

        // Command key shortcuts
        if modifierFlags == .command {
            switch event.keyCode {
            case 0x00:  // Cmd+A (Select All)
                selectAll(nil)
                return true
            case 0x06:  // Cmd+Z (Undo)
                undoManager?.undo()
                if let win = window as? NotesWindow {
                    win.saveCurrentNote()
                }
                return true
            case 0x07:  // Cmd+X (Cut)
                cut(nil)
                // Trigger autosave after cut
                if let win = window as? NotesWindow {
                    win.saveCurrentNote()
                }
                return true
            case 0x08:  // Cmd+C (Copy)
                copy(nil)
                return true
            case 0x09:  // Cmd+V (Paste)
                paste(nil)
                // Trigger autosave after paste
                if let win = window as? NotesWindow {
                    win.saveCurrentNote()
                }
                return true
            case 0x0D:  // Cmd+W (Close Window)
                NSApp.keyWindow?.close()
                return true
            case 0x1D:  // Cmd+Y (Redo)
                undoManager?.redo()
                // Trigger autosave after redo
                if let win = window as? NotesWindow {
                    win.saveCurrentNote()
                }
                return true
            case 0x21:  // Cmd+[ (Previous Note)
                prevNote()
                return true
            case 0x1E:  // Cmd+] (Next Note)
                nextNote()
                return true
            default:
                // Handle Cmd+1 through Cmd+9
                if let ch = event.charactersIgnoringModifiers?.first,
                    let n = ch.wholeNumberValue, (1...5).contains(n)
                {
                    switchNote(n - 1)
                    return true
                }
                return false
            }
        }

        return super.performKeyEquivalent(with: event)
    }
}
