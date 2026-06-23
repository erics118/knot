import Cocoa
import Defaults

extension NotesWindow {
    func scheduleSave() {
        pendingSaveTimer?.invalidate()

        let timer = Timer(timeInterval: 0.5, repeats: false) {
            [weak self] _ in
            self?.saveCurrentNote()
        }
        pendingSaveTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func saveCurrentNote() {
        pendingSaveTimer?.invalidate()
        pendingSaveTimer = nil

        guard let text = textView?.string else { return }
        var notes = Defaults[.notes]
        notes[Defaults[.currentNoteIndex]] = text
        Defaults[.notes] = notes
    }

    func switchToNote(_ newIndex: Int) {
        if newIndex != Defaults[.currentNoteIndex] {
            saveCurrentNote()
            Defaults[.currentNoteIndex] = newIndex % 5
            loadCurrentNote()
        }
    }

    func loadCurrentNote() {
        textView?.string = Defaults[.notes][Defaults[.currentNoteIndex]]
        updateStatusBar()
        updateWindowTitle()
    }
}
