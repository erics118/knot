import Defaults
import KeyboardShortcuts
import SwiftUI
import AppKit

struct GeneralSettingsView: View {
    @Default(.shortcutBehavior) var shortcutBehavior
    @Default(.color) var color
    @Default(.showCloseButton) var showCloseButton
    @Default(.showTitle) var showTitle
    @Default(.titleBarBehavior) var titleBarBehavior
    @Default(.showStatusBar) var showStatusBar
    @Default(.statusBarBehavior) var statusBarBehavior
    
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
            
            Toggle("Show Close Window Button", isOn: $showCloseButton)
                .onChange(of: showCloseButton) { _, newValue in
                    updateWindowButtons()
                }
            
            Toggle("Show Window Title", isOn: $showTitle)
            
            Picker("Show Title Bar:", selection: $titleBarBehavior) {
                ForEach(TitleBarBehavior.allCases, id: \.self) { behavior in
                    Text(behavior.displayName).tag(behavior)
                }
            }
            
            Picker("Show Status Bar:", selection: $statusBarBehavior) {
                ForEach(StatusBarBehavior.allCases, id: \.self) { behavior in
                    Text(behavior.displayName).tag(behavior)
                }
            }
        }
        .scenePadding()
    }
    
    private func updateWindowButtons() {
        DispatchQueue.main.async {
            for window in NSApp.windows {
                if window.title != "knot Settings" {
                    window.standardWindowButton(.closeButton)?.isHidden = !showCloseButton
                }
            }
        }
    }
}

class SettingsWindowController: NSWindowController {
    private var hostingController: NSHostingController<SettingsView>?
    
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 0, height: 0),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "knot Settings"
        
        let settingsView = SettingsView()
        let hostingController = NSHostingController(rootView: settingsView)
        
        // Set content view controller
        window.contentViewController = hostingController
        
        // Size window to fit content
        window.setContentSize(hostingController.view.fittingSize)
        
        // Allow the window to resize to fit content
        window.contentMinSize = NSSize(width: 600, height: 400)
        window.contentMaxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        
        // Hide the titlebar
        window.titlebarAppearsTransparent = true
        window.titlebarSeparatorStyle = .none
        
        window.setFrameAutosaveName("SettingsWindow")
        window.isMovableByWindowBackground = true
        
        self.init(window: window)
        
        // Store reference to hosting controller
        self.hostingController = hostingController
    }
}

struct SettingsView: View {
    var body: some View {
        GeneralSettingsView()
    }
}
