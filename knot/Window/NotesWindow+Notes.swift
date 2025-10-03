import Cocoa
import Defaults

extension NotesWindow {
    func setupAutosave() {
        autosaveTimer = Timer.scheduledTimer(
            withTimeInterval: 30.0,
            repeats: true
        ) { [weak self] _ in
            self?.saveCurrentNote()
        }
    }

    func saveCurrentNote() {
        guard let text = textView?.string else { return }
        var notes = Defaults[.notes]
        notes[Defaults[.currentNoteIndex]] = text
        Defaults[.notes] = notes
    }

    func switchToNote(_ newIndex: Int) {
        if newIndex != Defaults[.currentNoteIndex] {
            saveCurrentNote()
            Defaults[.currentNoteIndex] = newIndex
            loadCurrentNote()
        }
    }

    func loadCurrentNote() {
        textView?.string = Defaults[.notes][Defaults[.currentNoteIndex]]
        updateStatusBar()
        updateWindowTitle()
    }
}
