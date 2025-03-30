import Defaults
import KeyboardShortcuts
import SwiftUI

struct GeneralSettingsView: View {
    @Default(.shortcutBehavior) var shortcutBehavior
    @Default(.color) var color
    @Default(.padding) var padding
    
    var body: some View {
        Form {
            KeyboardShortcuts.Recorder("Shortcut:", name: .toggleFloatingNote)
            
            Picker("Shortcut Behavior", selection: $shortcutBehavior) {
                ForEach(ShortcutBehavior.allCases) { opt in
                    Text(opt.displayName).tag(opt)
                }
            }
            .pickerStyle(.radioGroup)
            
            ColorPicker("Background Color:", selection: $color)
            
            TextField("Padding:", value: $padding, formatter: NumberFormatter())
                .textFieldStyle(.roundedBorder)
        }
        .scenePadding()
    }
}

struct AppearanceSettingsView: View {
    
    var body: some View {
        Form {
            
        }
        .scenePadding()
    }
}


class SettingsWindowController: NSWindowController {
    private var hostingController: NSHostingController<SettingsView>?
    
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "knot Settings"
        
        let settingsView = SettingsView()
        let hostingController = NSHostingController(rootView: settingsView)
        
        // Allow the window to resize to fit content
        window.contentMinSize = NSSize(width: 600, height: 400)
        window.contentMaxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        
        // Hide the titlebar
        window.titlebarAppearsTransparent = true
        window.titlebarSeparatorStyle = .none
        
        window.setFrameAutosaveName("SettingsWindow")
        window.isMovableByWindowBackground = true
        
        window.contentViewController = hostingController
        
        self.init(window: window)
        
        // Store reference to hosting controller
        self.hostingController = hostingController
    }
    
}

struct SettingsView: View {
    var body: some View {
        //        TabView(selection: $selectedTab) {
        //            Tab("General", systemImage: "gear", value: 0 ) {
        //                GeneralSettingsView()
        //            }
        //            Tab("Appearance", systemImage: "paintpalette", value: 1) {
        //                AppearanceSettingsView()
        //            }
        //        }
        GeneralSettingsView()
            .scenePadding()
    }
}
