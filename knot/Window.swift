import Cocoa
import Defaults

class NotesWindow: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    override func cancelOperation(_ sender: Any?) {
        if Defaults[.closeOnEscape] {
            super.cancelOperation(sender)
        }
    }

    override func orderOut(_ sender: Any?) {
        saveCurrentNote()
        super.orderOut(sender)
    }

    override func close() {
        saveCurrentNote()
        super.close()
    }

    var closeButtonObserver: Defaults.Observation?
    var titleBarBehaviorObserver: Defaults.Observation?
    var titleBarObserver: Defaults.Observation?
    var statusBarVisibilityObserver: Defaults.Observation?
    var statusBarBehaviorObserver: Defaults.Observation?

    var textDidChangeObserver: NSObjectProtocol?

    var textView: NSTextView?
    var statusBarView: StatusBarView?
    var titlePaddingView: NSView?
    var pendingSaveTimer: Timer?

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

        // Show above all other windows
        self.level = .floating

        // Allow moving by background
        self.isMovableByWindowBackground = true

        // Flag as partially transparent
        self.isOpaque = false
        self.backgroundColor = .clear
        self.appearance = NSAppearance(named: .darkAqua)

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

        // Apply the initial title-bar preferences. Defaults observers only
        // handle subsequent changes.
        updateCloseButtonVisibility()
        updateTitleVisibility()
        updateTitleBarOpacity()

        // Setup text observer (must be after textView is created)
        setupTextObserver()

        // Set initial status bar visibility
        updateStatusBarVisibility()

        // Load note content
        loadCurrentNote()

        // Setup title
        updateWindowTitle()

        // Setup mouse tracking
        setupMouseTracking()
    }

    deinit {
        pendingSaveTimer?.invalidate()
    }

}

extension KnotApp {
    func setupWindow() {
        // Create window
        window = NotesWindow()
        window.makeKeyAndOrderFront(nil)
    }
}
