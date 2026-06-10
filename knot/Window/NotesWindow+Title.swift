import Cocoa
import Defaults

extension NotesWindow {

    func updateWindowTitle() {
        guard let text = textView?.string else { return }
        let firstLine = text.components(separatedBy: .newlines).first ?? ""
        self.title = "[\(Defaults[.currentNoteIndex] + 1)] " + firstLine
    }

    func updateTitleBarOpacity() {
        switch Defaults[.titleBarBehavior] {
        case .always:
            setTitleBarAlpha(1.0)
        case .onHover, .never:
            setTitleBarAlpha(0.0)
        }
    }

    func setTitleBarAlpha(_ alpha: CGFloat, animated: Bool = false) {
        guard let titlebarView = standardWindowButton(.closeButton)?.superview
        else { return }
        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                context.timingFunction = CAMediaTimingFunction(
                    name: .easeInEaseOut
                )
                titlebarView.animator().alphaValue = alpha
                titlePaddingView?.animator().alphaValue = alpha
            }
        } else {
            titlebarView.alphaValue = alpha
            titlePaddingView?.alphaValue = alpha
        }
    }

    func updateTitleVisibility() {
        self.titleVisibility = Defaults[.showTitle] ? .visible : .hidden
    }
}
