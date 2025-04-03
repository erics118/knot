import Cocoa
import SwiftUI
import Defaults
import KeyboardShortcuts

extension Defaults.Keys {
    static let padding = Key<CGFloat>("padding", default: 20)
    static let color = Key<Color>(
        "color",
        default: Color(red: 36.0 / 255.0, green: 36.0 / 255.0, blue: 36.0 / 255.0, opacity: 0.6))
    static let noteContent = Key<String>("noteContent", default: "")
    
    static let shortcutBehavior = Key<ShortcutBehavior>("shortcutBehavior", default: ShortcutBehavior.focusAndHide)
    static let showCharacterCount = Key<Bool>("showCharacterCount", default: true)
    static let showCloseButton = Key<Bool>("showCloseButton", default: true)
}

extension KeyboardShortcuts.Name {
    static let toggleFloatingNote = Self(
        "toggleFloatingNote",
        default: .init(.x, modifiers: [.command, .shift, .option, .control])
    )
}
