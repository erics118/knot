import Cocoa
import Defaults

extension NotesWindow {

    func updateWindowTitle() {
        guard let text = textView?.string else { return }
        let firstLine = text.components(separatedBy: .newlines).first ?? ""
        self.title =
            "[\(Defaults[.currentNoteIndex])] "
            + (firstLine.isEmpty
                ? "Note \(Defaults[.currentNoteIndex] + 1)" : firstLine)
    }

    func updateTitleBarOpacity() {
        if let titlebarView = self.standardWindowButton(.closeButton)?.superview
        {
            switch Defaults[.titleBarBehavior] {
            case .always:
                titlebarView.alphaValue = 1.0
                titlePaddingView?.alphaValue = 1.0
            case .onHover:
                titlebarView.alphaValue = 0.0
                titlePaddingView?.alphaValue = 0.0
            case .never:
                titlebarView.alphaValue = 0.0
                titlePaddingView?.alphaValue = 0.0
            }
        }
    }

    func updateTitleVisibility() {
        self.titleVisibility = Defaults[.showTitle] ? .visible : .hidden
    }
}
