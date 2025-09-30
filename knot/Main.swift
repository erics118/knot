import SwiftUI
import Defaults

@main
struct KnotApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            NotesView()
                .frame(minWidth: 400, minHeight: 200)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Settings") {
                    appDelegate.openSettings()
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
        
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var settingsWindowController: SettingsWindowController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupKeyboardShortcuts()
        configureWindows()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Save current note before quitting
        NotesViewModel.shared.saveCurrentNote()
    }
    
    private func configureWindows() {
        // Configure all windows to be floating panels
        for window in NSApp.windows {
            if window.title != "knot Settings" {
                window.level = .floating
                window.collectionBehavior = .canJoinAllSpaces
            }
        }
    }
    
    func openSettings() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController()
        }
        settingsWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
