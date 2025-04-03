import Cocoa
import Defaults

class KnotApp: NSObject, NSApplicationDelegate {
    var window: NotesWindow!
    
    var settingsWindowController: SettingsWindowController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupWindow()
        setupKeyboardShortcuts()
        setupMenuBar()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Save note content before quitting
        window.saveNoteContent()
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
