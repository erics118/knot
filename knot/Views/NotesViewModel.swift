import SwiftUI
import Defaults
import Combine

@MainActor
class NotesViewModel: ObservableObject {
    static let shared = NotesViewModel()
    
    @Published var currentNoteIndex: Int = Defaults[.currentNoteIndex] {
        didSet {
            if oldValue != currentNoteIndex {
                saveCurrentNote(at: oldValue)
                Defaults[.currentNoteIndex] = currentNoteIndex
                loadCurrentNote()
            }
        }
    }
    
    @Published var noteText: String = "" {
        didSet {
            updateStatusText()
        }
    }
    
    @Published var statusText: String = ""
    @Published var windowTitle: String = ""
    
    private var notes: [String] = Defaults[.notes]
    private var autosaveTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadCurrentNote()
        setupAutosave()
        setupDefaultsObservers()
    }
    
    private func setupDefaultsObservers() {
        // Observe notes changes from external sources
        Defaults.publisher(.notes)
            .sink { [weak self] change in
                self?.notes = change.newValue
                self?.loadCurrentNote()
            }
            .store(in: &cancellables)
        
        // Observe current note index changes
        Defaults.publisher(.currentNoteIndex)
            .sink { [weak self] change in
                if self?.currentNoteIndex != change.newValue {
                    self?.currentNoteIndex = change.newValue
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupAutosave() {
        autosaveTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.saveCurrentNote()
        }
    }
    
    func saveCurrentNote(at index: Int? = nil) {
        let indexToSave = index ?? currentNoteIndex
        guard indexToSave < notes.count else { return }
        notes[indexToSave] = noteText
        Defaults[.notes] = notes
    }
    
    private func loadCurrentNote() {
        guard currentNoteIndex < notes.count else { return }
        noteText = notes[currentNoteIndex]
        updateWindowTitle()
        updateStatusText()
    }
    
    func switchToNote(_ index: Int) {
        guard index >= 0 && index < 5 && index != currentNoteIndex else { return }
        currentNoteIndex = index
    }
    
    private func updateWindowTitle() {
        let firstLine = noteText.components(separatedBy: .newlines).first ?? ""
        windowTitle = "[\(currentNoteIndex)] " + (firstLine.isEmpty ? "Note \(currentNoteIndex + 1)" : firstLine)
    }
    
    private func updateStatusText() {
        let charCount = noteText.count
        let wordCount = noteText.split(separator: " ").count
        
        if Defaults[.showCharacterCount] {
            let characterString = charCount == 1 ? "character" : "characters"
            statusText = "\(charCount) \(characterString)"
        } else {
            let wordString = wordCount == 1 ? "word" : "words"
            statusText = "\(wordCount) \(wordString)"
        }
    }
    
    func toggleStatusMode() {
        Defaults[.showCharacterCount].toggle()
        updateStatusText()
    }
}
