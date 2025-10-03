import Cocoa
import Defaults

extension NotesWindow {
    func updateStatusBar() {
        guard let text = textView?.string else { return }
        statusBarView?.updateCount(from: text)
    }
}
