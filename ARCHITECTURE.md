# SwiftUI Architecture Diagram

## Application Structure

```
┌─────────────────────────────────────────────────────────────┐
│                         KnotApp                             │
│                     (SwiftUI App)                           │
│                                                             │
│  ┌───────────────────────────────────────────────────┐    │
│  │            WindowGroup                            │    │
│  │                                                   │    │
│  │  ┌─────────────────────────────────────────┐    │    │
│  │  │          NotesView                      │    │    │
│  │  │      (Main Window UI)                   │    │    │
│  │  │                                         │    │    │
│  │  │  ┌───────────────────────────────┐     │    │    │
│  │  │  │   NotesViewModel              │     │    │    │
│  │  │  │   (State Management)          │     │    │    │
│  │  │  │                               │     │    │    │
│  │  │  │  • noteText: String           │     │    │    │
│  │  │  │  • currentNoteIndex: Int      │     │    │    │
│  │  │  │  • statusText: String         │     │    │    │
│  │  │  │  • windowTitle: String        │     │    │    │
│  │  │  │                               │     │    │    │
│  │  │  │  Methods:                     │     │    │    │
│  │  │  │  • saveCurrentNote()          │     │    │    │
│  │  │  │  • loadCurrentNote()          │     │    │    │
│  │  │  │  • switchToNote(_:)           │     │    │    │
│  │  │  │  • toggleStatusMode()         │     │    │    │
│  │  │  └───────────────────────────────┘     │    │    │
│  │  │            ▲                            │    │    │
│  │  │            │ @StateObject               │    │    │
│  │  │            │                            │    │    │
│  │  │  ┌─────────┴──────────────────────┐    │    │    │
│  │  │  │  UI Components                 │    │    │    │
│  │  │  │                                │    │    │    │
│  │  │  │  • VisualEffectView (blur)    │    │    │    │
│  │  │  │  • TextEditor                 │    │    │    │
│  │  │  │  • StatusBarView              │    │    │    │
│  │  │  │  • Title bar padding          │    │    │    │
│  │  │  │                                │    │    │    │
│  │  │  │  View Modifiers:              │    │    │    │
│  │  │  │  • .keyboardShortcuts()       │    │    │    │
│  │  │  │  • .onHover()                 │    │    │    │
│  │  │  │  • .onAppear()                │    │    │    │
│  │  │  └────────────────────────────────┘    │    │    │
│  │  └─────────────────────────────────────────┘    │    │
│  └───────────────────────────────────────────────────┘    │
│                                                             │
│  ┌───────────────────────────────────────────────────┐    │
│  │         AppDelegate                               │    │
│  │    (NSApplicationDelegate)                        │    │
│  │                                                   │    │
│  │  Responsibilities:                                │    │
│  │  • Set accessory policy                           │    │
│  │  • Setup keyboard shortcuts                       │    │
│  │  • Configure window properties                    │    │
│  │  • Manage settings window                         │    │
│  └───────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                   Settings Window                           │
│              (Separate Window Controller)                   │
│                                                             │
│  ┌───────────────────────────────────────────────────┐    │
│  │      SettingsWindowController                     │    │
│  │      (NSWindowController)                         │    │
│  │                                                   │    │
│  │  ┌─────────────────────────────────────────┐    │    │
│  │  │         SettingsView                    │    │    │
│  │  │         (SwiftUI)                       │    │    │
│  │  │                                         │    │    │
│  │  │  ┌───────────────────────────────┐     │    │    │
│  │  │  │   GeneralSettingsView         │     │    │    │
│  │  │  │                               │     │    │    │
│  │  │  │  • Keyboard shortcut          │     │    │    │
│  │  │  │  • Shortcut behavior          │     │    │    │
│  │  │  │  • Background color           │     │    │    │
│  │  │  │  • Close button toggle        │     │    │    │
│  │  │  │  • Title bar behavior         │     │    │    │
│  │  │  │  • Status bar behavior        │     │    │    │
│  │  │  └───────────────────────────────┘     │    │    │
│  │  └─────────────────────────────────────────┘    │    │
│  └───────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

```
┌──────────────────────────────────────────────────────────────┐
│                     User Interactions                        │
└───────────────┬──────────────────────────────────────────────┘
                │
                ▼
┌───────────────────────────────────────────────────────────────┐
│                         NotesView                             │
│                                                               │
│  Keyboard Input ──────────────┐                              │
│  Mouse Hover ─────────────────┤                              │
│  Text Editing ────────────────┤                              │
│  Status Bar Click ────────────┤                              │
└───────────────────────────────┼───────────────────────────────┘
                                │
                                ▼
┌───────────────────────────────────────────────────────────────┐
│                      NotesViewModel                           │
│                                                               │
│  @Published Properties: ──────────────┐                      │
│    • noteText                         │                      │
│    • currentNoteIndex                 │                      │
│    • statusText                       │                      │
│    • windowTitle                      │                      │
│                                       │                      │
│  Methods:                             │                      │
│    • saveCurrentNote() ───────────────┤                      │
│    • loadCurrentNote()                │                      │
│    • switchToNote(_:)                 │                      │
│    • toggleStatusMode()               │                      │
└───────────────────────────────────────┼───────────────────────┘
                                        │
                                        ▼
┌───────────────────────────────────────────────────────────────┐
│                    Defaults (UserDefaults)                    │
│                                                               │
│  Stored Properties:                                           │
│    • notes: [String]                                          │
│    • currentNoteIndex: Int                                    │
│    • showCharacterCount: Bool                                 │
│    • color: Color                                             │
│    • showCloseButton: Bool                                    │
│    • showTitle: Bool                                          │
│    • titleBarBehavior: TitleBarBehavior                       │
│    • statusBarBehavior: StatusBarBehavior                     │
│    • shortcutBehavior: ShortcutBehavior                       │
└───────────────────────────────────────────────────────────────┘
                                        │
                                        │ Combine Publishers
                                        ▼
┌───────────────────────────────────────────────────────────────┐
│              Reactive Updates (via @Default)                  │
│                                                               │
│  Settings Changes ──────────────────────────▶ UI Updates     │
│  Note Changes ──────────────────────────────▶ Autosave       │
│  External Changes ──────────────────────────▶ Reload         │
└───────────────────────────────────────────────────────────────┘
```

## Component Interaction

```
┌─────────────────┐
│  Global Shortcut│
│   (Cmd+Opt+     │
│    Ctrl+Shift+X)│
└────────┬────────┘
         │
         ▼
┌────────────────────────────┐
│  KeyboardShortcuts Library │
│                            │
│  onKeyUp handler           │
└────────┬───────────────────┘
         │
         ▼
┌────────────────────────────┐
│  AppDelegate               │
│                            │
│  toggleWindowVisibility()  │
└────────┬───────────────────┘
         │
         ▼
┌────────────────────────────┐      ┌──────────────────┐
│  NSApp.windows             │─────▶│  Show/Hide       │
│                            │      │  based on        │
│  Find main window          │      │  shortcutBehavior│
└────────────────────────────┘      └──────────────────┘


┌─────────────────┐
│  Text Editing   │
│  in TextEditor  │
└────────┬────────┘
         │
         ▼
┌────────────────────────────┐
│  $viewModel.noteText       │
│  (Two-way binding)         │
└────────┬───────────────────┘
         │
         ▼
┌────────────────────────────┐
│  NotesViewModel            │
│                            │
│  noteText didSet { ... }   │
└────────┬───────────────────┘
         │
         ├─────────────────────────────┐
         │                             │
         ▼                             ▼
┌────────────────────┐    ┌────────────────────┐
│  updateStatusText()│    │  Trigger @Published│
│                    │    │  property update   │
└────────────────────┘    └──────────┬─────────┘
                                     │
                                     ▼
                          ┌────────────────────┐
                          │  SwiftUI rerenders │
                          │  StatusBarView     │
                          └────────────────────┘


┌─────────────────┐
│  Timer (30s)    │
│  in ViewModel   │
└────────┬────────┘
         │
         ▼
┌────────────────────────────┐
│  saveCurrentNote()         │
└────────┬───────────────────┘
         │
         ▼
┌────────────────────────────┐
│  Defaults[.notes] = notes  │
│                            │
│  Persisted to disk         │
└────────────────────────────┘
```

## View Hierarchy

```
NotesView (Main Container)
│
├── ZStack
│   │
│   ├── VisualEffectView (Background blur)
│   │   └── NSVisualEffectView (NSViewRepresentable)
│   │
│   ├── backgroundColor (Color overlay)
│   │
│   └── VStack (Content)
│       │
│       ├── Color.clear (Title bar padding)
│       │   └── .opacity(titleBarOpacity)
│       │       └── Animated based on hover/behavior
│       │
│       ├── TextEditor (Main editor)
│       │   ├── .font(.monospaced)
│       │   ├── .scrollContentBackground(.hidden)
│       │   ├── .padding(.horizontal, 20)
│       │   ├── .focused($isTextFocused)
│       │   └── .keyboardShortcuts()
│       │       ├── Cmd+W / Esc: Close
│       │       ├── Cmd+[/]: Previous/Next note
│       │       └── Cmd+1-5: Switch to note
│       │
│       └── StatusBarView (Character/word count)
│           ├── Button (Clickable)
│           └── .opacity(statusBarOpacity)
│               └── Animated based on hover/behavior
│
├── .onHover { } (Track mouse enter/exit)
├── .toolbar { } (Window title bar)
└── .onAppear { } (Configure window on first show)
```

## Thread Safety

```
┌─────────────────────────────────────────────────────────┐
│                  @MainActor                             │
│              (UI Thread Safety)                         │
│                                                         │
│  NotesViewModel: ObservableObject                       │
│    ├── All @Published properties on main thread        │
│    ├── All UI updates automatic                        │
│    └── Timer fires on main thread                      │
│                                                         │
│  SwiftUI Views                                          │
│    ├── All view updates on main thread                 │
│    ├── State changes trigger UI updates                │
│    └── No manual DispatchQueue needed                  │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│           Combine Publishers (Background)               │
│                                                         │
│  Defaults.publisher(.notes)                             │
│    └── .sink { [weak self] ... }                       │
│        └── Updates automatically on main thread        │
│                                                         │
│  Autosave Timer                                         │
│    └── Timer.scheduledTimer(...) { [weak self] ... }   │
│        └── Weak reference prevents retain cycles       │
└─────────────────────────────────────────────────────────┘
```

## Key Features Implementation

### 1. Floating Window Behavior
- Set in `NotesView.configureWindow()`
- `window.level = .floating`
- `window.collectionBehavior = .canJoinAllSpaces`

### 2. Title Bar on Hover
- Track mouse with `.onHover { hovering in ... }`
- Compute opacity: `titleBarOpacity` based on `titleBarBehavior`
- Animate with `withAnimation(.easeInEaseOut(duration: 0.2))`

### 3. Note Switching
- Keyboard shortcuts: Cmd+1-5, Cmd+[, Cmd+]
- ViewModel method: `switchToNote(_:)`
- Automatic save/load cycle

### 4. Autosave
- Timer in ViewModel: `Timer.scheduledTimer(withTimeInterval: 30.0)`
- Saves to UserDefaults via `Defaults[.notes]`
- Also saves on note switch and app termination

### 5. Status Bar Toggle
- Click handler in StatusBarView
- Toggles `Defaults[.showCharacterCount]`
- ViewModel recomputes statusText in `updateStatusText()`

### 6. Settings Window
- Separate NSWindowController (not part of main scene)
- SwiftUI content via NSHostingController
- Direct UserDefaults binding with `@Default`
- Changes reflected immediately in main window

### 7. Keyboard Shortcuts
- Global shortcut: KeyboardShortcuts library
- Local shortcuts: SwiftUI `.onKeyPress` modifiers
- Custom ViewModifier for reusability
