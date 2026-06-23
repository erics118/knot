import Cocoa
import Defaults

extension NotesWindow {
    func setupObservers() {
        closeButtonObserver = Defaults.observe(.showCloseButton) {
            [weak self] _ in
            self?.updateCloseButtonVisibility()
        }

        titleBarBehaviorObserver = Defaults.observe(.titleBarBehavior) {
            [weak self] _ in
            self?.updateTitleBarOpacity()
        }

        titleBarObserver = Defaults.observe(.showTitle) {
            [weak self] _ in
            self?.updateTitleVisibility()
        }

        statusBarBehaviorObserver = Defaults.observe(.statusBarBehavior) {
            [weak self] _ in
            self?.updateStatusBarVisibility()
        }

    }

    func updateCloseButtonVisibility() {
        standardWindowButton(.closeButton)?.isHidden =
            !Defaults[.showCloseButton]
    }

    func setupTextObserver() {
        textDidChangeObserver = NotificationCenter.default.addObserver(
            forName: NSText.didChangeNotification,
            object: textView,
            queue: .main
        ) { [weak self] _ in
            self?.updateStatusBar()
            self?.updateWindowTitle()
            self?.scheduleSave()
        }
    }
}
