import Cocoa
import Defaults
import KeyboardShortcuts
import SwiftUI

enum VisibilityBehavior: String, CaseIterable, Defaults.Serializable {
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
    static let fontSize = Key<CGFloat>("fontSize", default: 12)
    static let color = Key<Color>(
        "color",
        default: Color(
            red: 36.0 / 255.0,
            green: 36.0 / 255.0,
            blue: 36.0 / 255.0,
            opacity: 0.6
        )
    )
    static let textColor = Key<NSColor>("textColor", default: .white)
    static let linkColor = Key<NSColor>("linkColor", default: .linkColor)
    static let caretColor = Key<NSColor>("caretColor", default: .green)

    static let shortcutBehavior = Key<ShortcutBehavior>(
        "shortcutBehavior",
        default: ShortcutBehavior.focusAndHide
    )
    static let showCharacterCount = Key<Bool>(
        "showCharacterCount",
        default: true
    )
    static let showCloseButton = Key<Bool>("showCloseButton", default: true)
    static let showTitle = Key<Bool>("showTitle", default: true)
    static let closeOnEscape = Key<Bool>("closeOnEscape", default: false)

    static let titleBarBehavior = Key<VisibilityBehavior>(
        "titleBarBehavior",
        default: .onHover
    )
    static let statusBarBehavior = Key<VisibilityBehavior>(
        "statusBarBehavior",
        default: .always
    )

    static let notes = Key<[String]>("notes", default: ["", "", "", "", ""])
    static let currentNoteIndex = Key<Int>("currentNoteIndex", default: 0)
}

extension KeyboardShortcuts.Name {
    static let toggleFloatingNote = Self(
        "toggleFloatingNote",
        default: .init(.x, modifiers: [.command, .shift, .option, .control])
    )
}
