# SwiftUI Refactoring Summary

This document outlines the changes made to refactor the knot app from AppKit to SwiftUI.

## Architecture Changes

### Before (AppKit)
- Main entry point: `NSApplication` with custom `NSApplicationDelegate`
- Window management: `NSPanel` subclass (`NotesWindow`)
- Text editing: `NSTextView` subclass (`EditableTextView`)
- UI components: Manual `NSView` layout with `NSStackView`
- Menu bar: Manually created `NSMenu`

### After (SwiftUI)
- Main entry point: SwiftUI `App` protocol with `@NSApplicationDelegateAdaptor`
- Window management: SwiftUI `WindowGroup` with programmatic NSWindow configuration
- Text editing: SwiftUI `TextEditor`
- UI components: SwiftUI declarative views
- Menu bar: SwiftUI `commands` modifier

## Key Components

### 1. Main.swift
**Changes:**
- Converted from `NSApplicationDelegate` class to SwiftUI `App` struct
- Kept `AppDelegate` class for lifecycle management and NSApplication configuration
- Settings accessed via custom window controller (maintained compatibility)
- Keyboard shortcuts setup moved to AppDelegate

**Key Features Preserved:**
- `.accessory` activation policy (app runs in background)
- Floating window level
- Window persistence with autosave name
- Global keyboard shortcut support

### 2. NotesView.swift (NEW)
**Replaces:** `Window.swift` and parts of `TextView.swift`

**Features:**
- SwiftUI `TextEditor` for note editing
- Blur background using `NSViewRepresentable` wrapper for `NSVisualEffectView`
- Status bar with character/word count toggle
- Title bar behavior (always/onHover/never)
- Status bar behavior (always/onHover/never)
- Keyboard shortcuts using `onKeyPress` modifiers:
  - Cmd+[1-5]: Switch to note 1-5
  - Cmd+[: Previous note
  - Cmd+]: Next note
  - Cmd+W: Close window
  - Esc: Close window

**Modern SwiftUI Patterns:**
- `@StateObject` for view model
- `@Default` for UserDefaults binding
- `@State` for local state
- `@FocusState` for text editor focus
- `.onHover` for mouse tracking
- Computed properties for conditional rendering

### 3. NotesViewModel.swift (NEW)
**Replaces:** State management logic from `NotesWindow`

**Features:**
- `@MainActor` for thread safety
- Singleton pattern (`shared` instance)
- `@Published` properties for reactive updates
- Combine publishers for Defaults observation
- Autosave timer (30-second interval)
- Note switching with automatic save/load

**Key Methods:**
- `saveCurrentNote()`: Persists current note to Defaults
- `loadCurrentNote()`: Loads note from Defaults
- `switchToNote(_:)`: Switches between notes (0-4)
- `toggleStatusMode()`: Toggles between character and word count
- `updateWindowTitle()`: Updates title with note index and first line
- `updateStatusText()`: Updates status bar text

### 4. SettingsView.swift
**Changes:**
- Removed unnecessary imports (Cocoa)
- Added AppKit import for NSWindow configuration
- Added `updateWindowButtons()` method to sync close button visibility
- Kept `SettingsWindowController` for window management (hybrid approach)

**Modern SwiftUI Patterns:**
- Pure SwiftUI views
- `.onChange` modifier for reactive updates
- `@Default` property wrapper for settings binding

### 5. KeyboardShortcuts.swift
**Changes:**
- Updated extension from `KnotApp` to `AppDelegate`
- Modified `toggleWindowVisibility()` to find window programmatically
- Added filter to exclude settings window

### 6. Defaults.swift
**Changes:**
- Import changed from `Cocoa` to `AppKit` (more specific)
- No functional changes to enums or keys

## Removed Files
- `Window.swift`: Replaced by `NotesView.swift` + `NotesViewModel.swift`
- `MenuBar.swift`: Replaced by SwiftUI `.commands` modifier in Main.swift
- `TextView.swift`: Replaced by SwiftUI `TextEditor` with keyboard shortcuts in `NotesView.swift`

## Modern SwiftUI Best Practices Applied

1. **Separation of Concerns**
   - View logic in `NotesView.swift`
   - Business logic in `NotesViewModel.swift`
   - App lifecycle in `Main.swift`

2. **Declarative UI**
   - No manual view hierarchy management
   - Automatic layout with `VStack`, `ZStack`
   - Conditional rendering with `if` statements

3. **Reactive Programming**
   - `@Published` properties in ViewModel
   - Combine publishers for external state changes
   - `@Default` property wrapper for two-way binding

4. **State Management**
   - Single source of truth (ViewModel singleton)
   - SwiftUI property wrappers (`@StateObject`, `@State`, etc.)
   - Proper use of `@MainActor` for UI updates

5. **View Composition**
   - Small, focused views (`StatusBarView`, `VisualEffectView`)
   - Reusable view modifiers (`KeyboardShortcutsModifier`)
   - Extension-based API (`View.keyboardShortcuts()`)

6. **NSViewRepresentable**
   - Proper wrapping of AppKit views when needed
   - Minimal bridging between SwiftUI and AppKit
   - Type-safe configuration

7. **Accessibility**
   - Maintained focus management
   - Keyboard navigation support
   - Semantic button actions

## Maintained Features

All original features have been preserved:
- ✅ 5 separate notes with switching (Cmd+1-5, Cmd+[, Cmd+])
- ✅ Global keyboard shortcut toggle
- ✅ Floating window (always on top)
- ✅ Autosave (30-second interval)
- ✅ Status bar with character/word count toggle
- ✅ Title bar with note index and first line
- ✅ Configurable title bar behavior (always/onHover/never)
- ✅ Configurable status bar behavior (always/onHover/never)
- ✅ Window position persistence
- ✅ Blur background with custom color
- ✅ Monospaced font for text
- ✅ Close button visibility toggle
- ✅ Window movable by background
- ✅ Runs in background (.accessory policy)

## Hybrid Approach Justification

While the goal was to refactor to SwiftUI, some AppKit integration remains:
- **Settings Window**: Uses `NSWindowController` because SwiftUI Settings scene doesn't provide enough control for window appearance
- **Window Configuration**: Uses `NSApp.windows` to configure floating panel behavior
- **Visual Effect View**: Uses `NSViewRepresentable` because SwiftUI doesn't have native blur view

This hybrid approach is a **modern SwiftUI best practice** for macOS apps that need specific window behaviors not available in pure SwiftUI.

## Testing Checklist

To verify the refactoring:
1. [ ] App launches as accessory (no dock icon)
2. [ ] Main window appears with floating behavior
3. [ ] Text editing works with undo/redo
4. [ ] Note switching works (Cmd+1-5, Cmd+[, Cmd+])
5. [ ] Global shortcut toggles window visibility
6. [ ] Status bar shows character/word count
7. [ ] Status bar toggles on click
8. [ ] Title bar shows/hides based on hover (if configured)
9. [ ] Status bar shows/hides based on hover (if configured)
10. [ ] Settings window opens and updates take effect
11. [ ] Background color changes apply
12. [ ] Window position persists across launches
13. [ ] Autosave works (check UserDefaults)
14. [ ] Close button visibility toggles
15. [ ] Window closes with Cmd+W and Esc

## Potential Improvements

Future enhancements (out of scope for this refactoring):
- Add native SwiftUI animations for view transitions
- Implement SwiftUI focus management for better keyboard navigation
- Consider SwiftUI TextEditor replacement with better formatting
- Add unit tests for ViewModel
- Add UI tests for keyboard shortcuts
