import Cocoa
import Defaults

class NotesWindow: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    var closeButtonObserver: Defaults.Observation?
    var titleBarBehaviorObserver: Defaults.Observation?
    var titleBarObserver: Defaults.Observation?
    var statusBarVisibilityObserver: Defaults.Observation?
    var statusBarBehaviorObserver: Defaults.Observation?

    var textDidChangeObserver: NSObjectProtocol?

    var textView: NSTextView?
    var statusBarView: StatusBarView?
    var titlePaddingView: NSView?
    var autosaveTimer: Timer?
    var trackingArea: NSTrackingArea?

    convenience init() {
        self.init(
            contentRect: NSMakeRect(0, 0, 400, 200),
            styleMask: [
                .nonactivatingPanel,
                .resizable,
                .titled,
                .closable,
                .fullSizeContentView,
            ],
            backing: .buffered,
            defer: false
        )

        // Configure titlebar
        self.titlebarAppearsTransparent = true
        self.titlebarSeparatorStyle = .none

        // Set initial title bar opacity
        updateTitleBarOpacity()

        // Show above all other windows
        self.level = .floating

        // Allow moving by background
        self.isMovableByWindowBackground = true

        // Flag as partially transparent
        self.isOpaque = false

        // Save window position
        self.setFrameAutosaveName("NotesWindow")

        // Show in all spaces
        self.collectionBehavior = .canJoinAllSpaces

        // hide the miniaturize and zoom buttons
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.zoomButton)?.isHidden = true

        // setup observers
        setupObservers()

        // Setup content
        self.contentView = createContentView()

        // Load note content
        loadCurrentNote()

        // Setup title
        updateWindowTitle()

        // Setup autosave
        setupAutosave()

        // Setup mouse tracking
        setupMouseTracking()
    }

}

extension KnotApp {
    func setupWindow() {
        // Create window
        window = NotesWindow()
        window.makeKeyAndOrderFront(nil)
    }
}
