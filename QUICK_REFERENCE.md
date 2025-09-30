# SwiftUI Refactoring - Quick Reference

## What Was Done

This project was successfully refactored from AppKit to SwiftUI while maintaining all functionality.

## Files Changed

### Removed (3 files, 579 lines)
- ❌ `knot/Window.swift` - 444 lines of manual NSPanel/NSView layout
- ❌ `knot/MenuBar.swift` - 42 lines of NSMenu setup  
- ❌ `knot/Views/TextView.swift` - 93 lines of custom NSTextView

### Added (2 files, 323 lines)
- ✅ `knot/Views/NotesView.swift` - 219 lines of SwiftUI views
- ✅ `knot/Views/NotesViewModel.swift` - 104 lines of state management

### Modified (4 files)
- 🔧 `knot/Main.swift` - Converted to SwiftUI App
- 🔧 `knot/KeyboardShortcuts.swift` - Updated for new delegate
- 🔧 `knot/Views/SettingsView.swift` - Cleaned up imports
- 🔧 `knot/Defaults.swift` - Minor import update

### Documentation (3 files)
- 📄 `REFACTORING.md` - Complete refactoring guide
- 📄 `CODE_COMPARISON.md` - Before/after code examples
- 📄 `ARCHITECTURE.md` - Visual architecture diagrams

## Code Reduction

```
Before: 846 lines
After:  616 lines
Saved:  230 lines (27% reduction)
```

## Key SwiftUI Patterns Used

### 1. App Structure
```swift
@main
struct KnotApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            NotesView()
        }
    }
}
```

### 2. State Management
```swift
@MainActor
class NotesViewModel: ObservableObject {
    @Published var noteText: String = ""
    @Published var statusText: String = ""
}
```

### 3. Reactive Views
```swift
struct NotesView: View {
    @StateObject private var viewModel = NotesViewModel.shared
    @Default(.color) var backgroundColor
    
    var body: some View {
        TextEditor(text: $viewModel.noteText)
    }
}
```

### 4. Custom View Modifiers
```swift
extension View {
    func keyboardShortcuts() -> some View {
        modifier(KeyboardShortcutsModifier())
    }
}
```

### 5. AppKit Bridging
```swift
struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        return view
    }
}
```

## Feature Checklist

All original features maintained:

- ✅ 5 notes with tab switching (Cmd+1-5, Cmd+[, Cmd+])
- ✅ Global keyboard shortcut toggle
- ✅ Floating window (always on top)
- ✅ Autosave every 30 seconds
- ✅ Status bar (character/word count toggle)
- ✅ Title bar with note index & first line
- ✅ Configurable behaviors (always/onHover/never)
- ✅ Window position persistence
- ✅ Blur background + custom color
- ✅ Settings window
- ✅ Close button visibility toggle
- ✅ Accessory app mode (no dock icon)

## Benefits Achieved

### Code Quality
- **Declarative UI**: Easier to read and maintain
- **Separation of concerns**: View/ViewModel split
- **Type safety**: SwiftUI property wrappers
- **Less boilerplate**: 27% code reduction

### Modern Practices
- **Reactive programming**: Combine publishers
- **Thread safety**: @MainActor
- **Memory management**: Weak references
- **Reusability**: View modifiers and components

### Maintainability
- **Future-proof**: Using Apple's recommended framework
- **Testability**: View logic separated from business logic
- **Documentation**: Comprehensive guides
- **Clarity**: Declarative code is self-documenting

## Quick Navigation

| File | Purpose |
|------|---------|
| `Main.swift` | App entry point, delegate setup |
| `Views/NotesView.swift` | Main window UI, keyboard shortcuts |
| `Views/NotesViewModel.swift` | State management, business logic |
| `Views/SettingsView.swift` | Settings UI |
| `KeyboardShortcuts.swift` | Global shortcut handling |
| `Defaults.swift` | UserDefaults keys and enums |

## Build & Run

This is an Xcode project. To build:

1. Open `knot.xcodeproj` in Xcode
2. Select the knot scheme
3. Press Cmd+R to build and run

Or use `xcodebuild`:
```bash
xcodebuild -project knot.xcodeproj -scheme knot
```

## Testing

See `REFACTORING.md` for complete testing checklist.

Quick verification:
1. App launches without dock icon
2. Window is floating (stays on top)
3. Text editing works
4. Cmd+1-5 switches notes
5. Global shortcut toggles window
6. Settings window opens (Cmd+,)
7. Changes persist after restart

## For Developers

### To Add a New Feature

1. **State**: Add to `NotesViewModel`
   ```swift
   @Published var newProperty: Type = defaultValue
   ```

2. **UI**: Add to `NotesView`
   ```swift
   Text(viewModel.newProperty)
   ```

3. **Persistence**: Add to `Defaults.swift`
   ```swift
   static let newKey = Key<Type>("newKey", default: defaultValue)
   ```

### To Modify Keyboard Shortcuts

Edit `KeyboardShortcutsModifier` in `NotesView.swift`:
```swift
.onKeyPress("x", modifiers: .command) {
    // Your action
    return .handled
}
```

### To Change Window Behavior

Modify `configureWindow()` in `NotesView.swift`:
```swift
window.level = .floating  // Window level
window.collectionBehavior = .canJoinAllSpaces  // Spaces
```

## Common Issues & Solutions

### Issue: Window doesn't stay on top
**Solution**: Check `window.level = .floating` in `configureWindow()`

### Issue: Keyboard shortcuts not working
**Solution**: Grant accessibility permissions in System Preferences

### Issue: Settings not persisting
**Solution**: Check `Defaults[.key]` usage and autosave timer

### Issue: Window position not saved
**Solution**: Verify `setFrameAutosaveName("NotesWindow")` is set

## Documentation Files

- **README.md** - Original project documentation
- **REFACTORING.md** (7.3 KB) - Detailed refactoring process and testing
- **CODE_COMPARISON.md** (10 KB) - Side-by-side code comparisons
- **ARCHITECTURE.md** (14.4 KB) - Visual diagrams and architecture
- **QUICK_REFERENCE.md** (this file) - Quick lookup guide

## Next Steps

The refactoring is complete. Possible future enhancements:

1. Add SwiftUI animations for smoother transitions
2. Implement SwiftUI focus management
3. Add unit tests for ViewModel
4. Add UI tests for keyboard shortcuts
5. Consider rich text formatting
6. Add iCloud sync support
7. Implement custom TextEditor for better control

## Credits

Refactored by GitHub Copilot using modern SwiftUI best practices.
Original app by erics118.
