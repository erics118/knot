import Cocoa
import Defaults

class NotesWindow: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
    
    private var colorObserver: Defaults.Observation?
    private var closeWindowButtonObserver: Defaults.Observation?
    private var backgroundView: NSView?
    private var notesView: NSScrollView?
    private var textView: NSTextView?
    private var statusBar: NSView?
    private var statusField: NSTextField?
    private var autosaveTimer: Timer?
    private var trackingArea: NSTrackingArea?
    
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
        self.titleVisibility = .visible
        self.title = "Notes"
        
        // Show above all other windows
        self.level = .floating
        
        // Allow moving by background
        self.isMovableByWindowBackground = true
        
        // Flag as partially transparent
        self.isOpaque = false
        
        // Hide window buttons
        self.standardWindowButton(.zoomButton)?.isHidden = true
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        
        // Control close button visibility based on preference
        self.standardWindowButton(.closeButton)?.isHidden = !Defaults[.showCloseButton]
        
        // Save window position
        self.setFrameAutosaveName("NotesWindow")
        
        // Show in all spaces
        self.collectionBehavior = .canJoinAllSpaces
        
        // Observe color changes
        self.colorObserver = Defaults.observe(.color) { [weak self] change in
            self?.backgroundView?.layer?.backgroundColor = change.newValue.cgColor
        }
        
        // Observe close button preference changes
        self.closeWindowButtonObserver = Defaults.observe(.showCloseButton) { [weak self] change in
            self?.standardWindowButton(.closeButton)?.isHidden = !change.newValue
        }
        
        // Setup content
        self.contentView = createContentView()
        
        // Setup autosave
        setupAutosave()
        
        // Setup mouse tracking
        setupMouseTracking()
        
        // Initially hide title bar
        if let titlebarView = self.standardWindowButton(.closeButton)?.superview {
            titlebarView.alphaValue = 0.0
        }
    }
    
    deinit {
        colorObserver?.invalidate()
        autosaveTimer?.invalidate()
        if let trackingArea = trackingArea {
            contentView?.removeTrackingArea(trackingArea)
        }
    }
    
    private func setupAutosave() {
        // Save every 30 seconds
        autosaveTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.saveNoteContent()
        }
    }
    
    public func saveNoteContent() {
        guard let text = textView?.string else { return }
        Defaults[.noteContent] = text
    }
    
    private func createBlurView(frame: NSRect) -> NSVisualEffectView {
        let view = NSVisualEffectView(frame: frame)
        view.material = .hudWindow
        view.blendingMode = .behindWindow
        view.state = .active
        view.autoresizingMask = [.width, .height]
        
        return view
    }
    
    private func createBackgroundView(frame: NSRect) -> NSView {
        let view = NSView(frame: frame)
        view.wantsLayer = true
        view.layer?.backgroundColor = Defaults[.color].cgColor
        view.autoresizingMask = [.width, .height]
        self.backgroundView = view
        return view
    }
    
    private func createStatusBar(frame: NSRect) -> NSView {
        let container = NSView(frame: frame)
        container.wantsLayer = true
        container.autoresizingMask = [.width, .height]
        
        // Status text field
        let statusField = NSTextField(frame: container.bounds)
        statusField.isEditable = false
        statusField.isBordered = false
        statusField.drawsBackground = false
        statusField.textColor = .tertiaryLabelColor
        statusField.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        statusField.alignment = .center
        statusField.autoresizingMask = [.width, .height]
        container.addSubview(statusField)
        
        // Create a button to handle clicks
        let button = NSButton(frame: container.bounds)
        button.bezelStyle = .regularSquare
        button.isBordered = false
        button.title = ""
        button.target = self
        button.action = #selector(toggleStatusBar)
        button.autoresizingMask = [.width, .height]
        container.addSubview(button)
        
        // Store references
        self.statusBar = container
        self.statusField = statusField
        
        return container
    }
    
    @objc private func toggleStatusBar() {
        Defaults[.showCharacterCount].toggle()
        updateStatusBar()
    }
    
    private func updateStatusBar() {
        guard let text = textView?.string else { return }
        let charCount = text.count
        let wordCount = text.split(separator: " ").count
        
        if Defaults[.showCharacterCount] {
            let characterString = charCount == 1 ? "character" : "characters"
            statusField?.stringValue = "\(charCount) \(characterString)"
        } else {
            let wordString = wordCount == 1 ? "word" : "words"
            statusField?.stringValue = "\(wordCount) \(wordString)"
        }
    }
    
    private func createNotesView(frame: NSRect) -> NSScrollView {
        let scrollView = NSScrollView(frame: frame)
        scrollView.autoresizingMask = [.width, .height]
        scrollView.wantsLayer = true
        scrollView.drawsBackground = false
        
        let textView = EditableTextView(frame: scrollView.bounds)
        textView.isRichText = false
        textView.autoresizingMask = [.width, .height]
        textView.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.drawsBackground = false
        textView.isEditable = true
        textView.isSelectable = true
        textView.wantsLayer = true
        
        // Enable undo
        textView.allowsUndo = true
        
        // Set text container insets for horizontal padding only
        textView.textContainerInset = NSSize(
            width: 20,
            height: 0
        )
        
        textView.string = Defaults[.noteContent]
        textView.insertionPointColor = .green
        textView.usesAdaptiveColorMappingForDarkAppearance = true
        
        // Observe text changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange),
            name: NSText.didChangeNotification,
            object: textView
        )
        
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder
        
        self.notesView = scrollView
        self.textView = textView
        return scrollView
    }
    
    @objc private func textDidChange() {
        updateStatusBar()
        // saveNoteContent()
    }
    
    private func createContentView() -> NSView {
        let containerView = NSView(frame: self.frame)
        containerView.wantsLayer = true
        
        // Add blur effect
        let blurView = createBlurView(frame: containerView.bounds)
        containerView.addSubview(blurView)
        
        // Add a background color
        let backgroundView = createBackgroundView(frame: containerView.bounds)
        containerView.addSubview(backgroundView)
        
        let statusBarHeight: CGFloat = 30
        // Add scrollable text view
        let notesView = createNotesView(frame: containerView.bounds.insetBy(
            dx: 0,
            dy: statusBarHeight
        ))
        containerView.addSubview(notesView)
        
        // Add status bar
        let statusBarFrame = NSRect(
            x: 0,
            y: 0,
            width: containerView.bounds.width,
            height: statusBarHeight
        )
        let statusBar = createStatusBar(frame: statusBarFrame)
        statusBar.frame.origin.y = (statusBarHeight - statusBar.frame.height - 10) / 2
        containerView.addSubview(statusBar)
        
        // Initial status update
        updateStatusBar()
        
        return containerView
    }
    
    private func setupMouseTracking() {
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways, .inVisibleRect]
        trackingArea = NSTrackingArea(rect: .zero, options: options, owner: self, userInfo: nil)
        contentView?.addTrackingArea(trackingArea!)
    }
    
    override func mouseEntered(with event: NSEvent) {
        if let titlebarView = self.standardWindowButton(.closeButton)?.superview {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                titlebarView.animator().alphaValue = 1.0
            }
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        if let titlebarView = self.standardWindowButton(.closeButton)?.superview {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                titlebarView.animator().alphaValue = 0.0
            }
        }
    }
}

extension KnotApp {
    func setupWindow() {
        // Create window
        window = NotesWindow()
        window.makeKeyAndOrderFront(nil)
    }
}
