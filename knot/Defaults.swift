import Cocoa
import SwiftUI
import Defaults
import KeyboardShortcuts

enum TitleBarBehavior: String, CaseIterable, Defaults.Serializable {
    case always
    case onHover
    case never
    
    var displayName: String {
        switch self {
        case .always: return "Always"
        case .onHover: return "On Hover"
        case .never: return "Never"
        }
    }
}

extension Defaults.Keys {
    static let padding = Key<CGFloat>("padding", default: 20)
    static let color = Key<Color>("color", default: Color(red: 36.0 / 255.0, green: 36.0 / 255.0, blue: 36.0 / 255.0, opacity: 0.6))
    
    static let shortcutBehavior = Key<ShortcutBehavior>("shortcutBehavior", default: ShortcutBehavior.focusAndHide)
    static let showCharacterCount = Key<Bool>("showCharacterCount", default: true)
    static let showCloseButton = Key<Bool>("showCloseButton", default: true)
    static let showMinimizeButton = Key<Bool>("showMinimizeButton", default: true)
    static let showZoomButton = Key<Bool>("showZoomButton", default: true)
    static let showTitle = Key<Bool>("showTitle", default: true)
    
    static let titleBarBehavior = Key<TitleBarBehavior>("titleBarBehavior", default: .onHover)
    
    static let notes = Key<[String]>("notes", default: [])
    static let currentNoteIndex = Key<Int>("currentNoteIndex", default: 0)

}

extension KeyboardShortcuts.Name {
    static let toggleFloatingNote = Self(
        "toggleFloatingNote",
        default: .init(.x, modifiers: [.command, .shift, .option, .control])
    )
}
