import Cocoa
import Defaults

class NotesWindow: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
    
    private var colorObserver: Defaults.Observation?
    private var closeButtonObserver: Defaults.Observation?
    private var minimizeButtonObserver: Defaults.Observation?
    private var zoomButtonObserver: Defaults.Observation?
    private var titleBarBehaviorObserver: Defaults.Observation?
    private var titleBarObserver: Defaults.Observation?
    private var statusBarVisibilityObserver: Defaults.Observation?
    private var statusBarBehaviorObserver: Defaults.Observation?
    
    private var backgroundView: NSView?
    private var notesView: NSScrollView?
    private var textView: NSTextView?
    private var statusBar: NSView?
    private var statusButton: NSButton?
    private var titlePaddingView: NSView?
    //private var noteTabs: [NSButton] = []
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
        
        // Observe color changes
        self.colorObserver = Defaults.observe(.color) { [weak self] change in
            self?.backgroundView?.layer?.backgroundColor = change.newValue.cgColor
        }
        
        // Observe close button preference changes
        self.closeButtonObserver = Defaults.observe(.showCloseButton) { [weak self] change in
            self?.standardWindowButton(.closeButton)?.isHidden = !change.newValue
        }
        
        // Observe close button preference changes
        self.minimizeButtonObserver = Defaults.observe(.showMinimizeButton) { [weak self] change in
            self?.standardWindowButton(.miniaturizeButton)?.isHidden = !change.newValue
        }
        // Observe close button preference changes
        self.zoomButtonObserver = Defaults.observe(.showZoomButton) { [weak self] change in
            self?.standardWindowButton(.zoomButton)?.isHidden = !change.newValue
        }
        
        self.titleBarBehaviorObserver = Defaults.observe(.titleBarBehavior) { [weak self] change in
            self?.updateTitleBarOpacity()
        }
        
        self.titleBarObserver = Defaults.observe(.showTitle) { [weak self] change in
            self?.updateTitleVisibility()
        }
        
        // Observe status bar behavior preference changes
        self.statusBarBehaviorObserver = Defaults.observe(.statusBarBehavior) { [weak self] _ in
            self?.updateStatusBarOpacity()
        }
        
        // Setup content
        self.contentView = createContentView()
        
        // Load note content
        loadCurrentNote()
        
        // TODO: onstartup, the selected tab isnt shown as green, even though the code runs
        updateNoteTabs()
        
        // Setup title
        updateWindowTitle()
        
        // Setup autosave
        setupAutosave()
        
        // Setup mouse tracking
        setupMouseTracking()
    }
    
    
    private func setupAutosave() {
        // Save every 30 seconds
        autosaveTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.saveCurrentNote()
        }
    }
    
    public func saveCurrentNote() {
        guard let text = textView?.string else { return }
        var notes = Defaults[.notes]
        notes[Defaults[.currentNoteIndex]] = text
        Defaults[.notes] = notes
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
        container.autoresizingMask = [.width, .minYMargin]
        
        // Create a button to handle clicks and display status
        let statusButton = NSButton(frame: container.bounds)
        statusButton.bezelStyle = .regularSquare
        statusButton.isBordered = false
        statusButton.title = ""
        statusButton.target = self
        statusButton.action = #selector(toggleStatusBar)
        statusButton.autoresizingMask = [.width, .height]
        statusButton.alignment = .center
        statusButton.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        statusButton.contentTintColor = .tertiaryLabelColor
        container.addSubview(statusButton)
        
        // Store references
        self.statusBar = container
        self.statusButton = statusButton
        
        return container
    }
    
    
    @objc private func toggleStatusBar() {
        Defaults[.showCharacterCount].toggle()
        updateStatusBar()
    }
    
    @objc private func switchNote(_ sender: NSButton) {
        switchToNote(sender.tag)
    }
    
    func switchToNote(_ newIndex: Int) {
        if newIndex != Defaults[.currentNoteIndex] {
            // Save current note
            saveCurrentNote()
            
            // Switch to new note
            Defaults[.currentNoteIndex] = newIndex
            
            // Update UI
            updateNoteTabs()
            
            // Load the note
            loadCurrentNote()
        }
    }
    
    private func updateNoteTabs() {
        //print("updating note tabs")
        //for (index, button) in noteTabs.enumerated() {
        //    if index == Defaults[.currentNoteIndex] {
        //        print("set \(index) to green")
        //        button.layer?.backgroundColor = NSColor.green.cgColor
        //    } else {
        //        button.layer?.backgroundColor = NSColor.clear.cgColor
        //    }
        //}
    }
    
    private func loadCurrentNote() {
        textView?.string = Defaults[.notes][Defaults[.currentNoteIndex]]
        updateStatusBar()
        updateWindowTitle()
    }
    
    private func updateStatusBar() {
        guard let text = textView?.string else { return }
        let charCount = text.count
        let wordCount = text.split(separator: " ").count
        
        if Defaults[.showCharacterCount] {
            let characterString = charCount == 1 ? "character" : "characters"
            statusButton?.title = "\(charCount) \(characterString)"
        } else {
            let wordString = wordCount == 1 ? "word" : "words"
            statusButton?.title = "\(wordCount) \(wordString)"
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
        updateWindowTitle()
    }
    
    private func updateWindowTitle() {
        guard let text = textView?.string else { return }
        let firstLine = text.components(separatedBy: .newlines).first ?? ""
        self.title = "[\(Defaults[.currentNoteIndex])]" + (firstLine.isEmpty ? "Note \(Defaults[.currentNoteIndex] + 1)" : firstLine)
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

        // Main vertical stack view
        let mainStackView = NSStackView()
        mainStackView.orientation = .vertical
        mainStackView.spacing = 0
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.distribution = .fill
        containerView.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])

        // Title padding view
        let titlePaddingView = NSView()
        titlePaddingView.translatesAutoresizingMaskIntoConstraints = false
        titlePaddingView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        titlePaddingView.wantsLayer = true
        self.titlePaddingView = titlePaddingView
        
        let statusBarHeight: CGFloat = 30
        
        let statusBar = createStatusBar(frame: NSRect(x: 0, y: 0, width: containerView.bounds.width, height: statusBarHeight))
        statusBar.heightAnchor.constraint(equalToConstant: statusBarHeight).isActive = true
        
        // Scrollable text view
        let notesView = createNotesView(frame: .zero)
        notesView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add views to stack view in order: title padding, notes content, status bar
        mainStackView.addArrangedSubview(titlePaddingView)
        mainStackView.addArrangedSubview(notesView)
        mainStackView.addArrangedSubview(statusBar)
        
        statusBar.widthAnchor.constraint(equalTo: mainStackView.widthAnchor).isActive = true
        notesView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor).isActive = true
        
        // Initial status update
        updateStatusBar()
        
        // Initial visibility update
        updateStatusBarVisibility()
        
        return containerView
    }
    
    private func setupMouseTracking() {
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways, .inVisibleRect]
        trackingArea = NSTrackingArea(rect: .zero, options: options, owner: self, userInfo: nil)
        contentView?.addTrackingArea(trackingArea!)
    }
    
    private func updateTitleBarOpacity() {
        if let titlebarView = self.standardWindowButton(.closeButton)?.superview {
            switch Defaults[.titleBarBehavior] {
            case .always:
                titlebarView.alphaValue = 1.0
                titlePaddingView?.alphaValue = 1.0
            case .onHover:
                titlebarView.alphaValue = 0.0
                titlePaddingView?.alphaValue = 0.0
            case .never:
                titlebarView.alphaValue = 0.0
                titlePaddingView?.alphaValue = 0.0
            }
        }
    }
    
    private func updateStatusBarOpacity() {
        guard let statusBar = self.statusBar else { return }
        
        switch Defaults[.statusBarBehavior] {
        case .always:
            statusBar.alphaValue = 1.0
        case .onHover:
            statusBar.alphaValue = 0.0
        case .never:
            statusBar.alphaValue = 0.0
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        if Defaults[.titleBarBehavior] == .onHover {
            if let titlebarView = self.standardWindowButton(.closeButton)?.superview {
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.2
                    context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    titlebarView.animator().alphaValue = 1.0
                    titlePaddingView?.animator().alphaValue = 1.0
                }
            }
        }
        
        if Defaults[.statusBarBehavior] == .onHover {
            if let statusBar = self.statusBar {
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.2
                    context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    statusBar.animator().alphaValue = 1.0
                }
            }
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        if Defaults[.titleBarBehavior] == .onHover {
            if let titlebarView = self.standardWindowButton(.closeButton)?.superview {
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.2
                    context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    titlebarView.animator().alphaValue = 0.0
                    titlePaddingView?.animator().alphaValue = 0.0
                }
            }
        }
        
        if Defaults[.statusBarBehavior] == .onHover {
            if let statusBar = self.statusBar {
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.2
                    context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    statusBar.animator().alphaValue = 0.0
                }
            }
        }
    }
    
    private func updateTitleVisibility() {
        self.titleVisibility = Defaults[.showTitle] ? .visible : .hidden
    }
    
    private func updateStatusBarVisibility() {
        updateStatusBarOpacity()
    }
}

extension KnotApp {
    func setupWindow() {
        // Create window
        window = NotesWindow()
        window.makeKeyAndOrderFront(nil)
    }
}
