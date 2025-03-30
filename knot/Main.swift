import Cocoa
import Defaults

class KnotApp: NSObject, NSApplicationDelegate {
    var window: NotesWindow!
    var textView: NSTextView!
    
    var settingsWindowController: SettingsWindowController?
    
    fileprivate func setupAutoSave() {
        // Observe text changes and save periodically
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(saveNoteContent),
            name: NSText.didChangeNotification,
            object: textView
        )
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupWindow()
        setupKeyboardShortcuts()
        setupMenuBar()
        setupAutoSave()
    }
    
    @objc fileprivate func saveNoteContent() {
        Defaults[.noteContent] = textView.string
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Ensure final save when app closes
        saveNoteContent()
        
        // Remove autosave observer
        NotificationCenter.default.removeObserver(self)
    }
}

@main
class Main {
    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        let delegate = KnotApp()
        app.delegate = delegate
        app.run()
    }
}
