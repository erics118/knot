import Cocoa
import KeyboardShortcuts
import Defaults

enum ShortcutBehavior: String, Hashable, Codable, Defaults.Serializable, CaseIterable, Identifiable {
    case focusAndHide
    case showAndHide
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .focusAndHide:
            return "Focus or Hide Window"
        case .showAndHide:
            return "Show or Hide Window"
        }
    }
}

extension KnotApp {
    fileprivate func checkAccessibilityPermissions() {
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        let options = [checkOptPrompt: true]
        
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary?)
        
        if !accessEnabled {
            let alert = NSAlert()
            alert.messageText = "Accessibility Permissions Required"
            alert.informativeText = "Please enable accessibility permissions in System Preferences to use global shortcuts."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Open System Preferences")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                NSWorkspace.shared.open(
                    URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            }
        }
    }
    
    fileprivate func toggleWindowVisibility() {
        if window.isKeyWindow {
            window.orderOut(nil)
        } else {
            window.makeKeyAndOrderFront(nil)
        }
    }
    
    
    func setupKeyboardShortcuts() {
        checkAccessibilityPermissions()
        
        KeyboardShortcuts.onKeyUp(for: .toggleFloatingNote) {
            self.toggleWindowVisibility()
        }
    }
}
