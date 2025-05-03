import Cocoa

extension KnotApp {
    @objc fileprivate func openSettings() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController()
        }
        settingsWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func setupMenuBar() {
        let mainMenu = NSMenu()
        
        // App Menu
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        
        // Settings Menu Item
        let settingsMenuItem = NSMenuItem(
            title: "Settings",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsMenuItem.keyEquivalentModifierMask = .command
        appMenu.addItem(settingsMenuItem)
        
        // Quit Menu Item
        let quitMenuItem = NSMenuItem(
            title: "Quit",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        quitMenuItem.keyEquivalentModifierMask = .command
        appMenu.addItem(quitMenuItem)
        
        NSApp.mainMenu = mainMenu
    }
}
