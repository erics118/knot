import Cocoa
import Defaults

class EditableTextView: NSTextView {
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        
        // Command key shortcuts
        if modifierFlags == .command {
            switch event.keyCode {
            case 0x00:  // Cmd+A (Select All)
                selectAll(nil)
                return true
            case 0x06:  // Cmd+Z (Undo)
                undoManager?.undo()
                return true
            case 0x07:  // Cmd+X (Cut)
                cut(nil)
                return true
            case 0x08:  // Cmd+C (Copy)
                copy(nil)
                return true
            case 0x09:  // Cmd+V (Paste)
                paste(nil)
                return true
            case 0x0D:  // Cmd+W (Close Window)
                NSApp.keyWindow?.close()
                return true
            case 0x1D:  // Cmd+Y (Redo)
                undoManager?.redo()
                return true
            default:
                return false
            }
        }
        
        // Command + Shift key shortcuts
        if modifierFlags == [.command, .shift] {
            switch event.keyCode {
            case 0x07:  // Cmd+Shift+C (Copy Style)
                copyFont(nil)
                return true
            case 0x09:  // Cmd+Shift+V (Paste Style)
                pasteFont(nil)
                return true
            case 0x1B:  // Cmd+Shift+Z (Redo)
                undoManager?.redo()
                return true
            default:
                return false
            }
        }
        
        // Command + Option key shortcuts
        if modifierFlags == [.command, .option] {
            switch event.keyCode {
            case 0x00:  // Cmd+Option+A (Select All in Line)
                selectLine(nil)
                return true
            case 0x06:  // Cmd+Option+Z (Redo)
                undoManager?.redo()
                return true
            default:
                return false
            }
        }
        
        return super.performKeyEquivalent(with: event)
    }
}
