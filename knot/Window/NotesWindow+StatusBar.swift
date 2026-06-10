import Cocoa
import Defaults

extension NotesWindow {
    func updateStatusBar() {
        guard let text = textView?.string else { return }
        statusBarView?.updateCount(from: text)
    }

    func updateStatusBarVisibility() {
        guard let statusBar = statusBarView else { return }
        switch Defaults[.statusBarBehavior] {
        case .always:
            statusBar.alphaValue = 1.0
        case .onHover, .never:
            statusBar.alphaValue = 0.0
        }
    }
}
