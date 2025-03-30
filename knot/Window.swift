import Cocoa
import Defaults

class NotesWindow: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
    
    convenience init() {
        self.init(
            contentRect: NSMakeRect(0, 0, 400, 200),
            styleMask: [
                .nonactivatingPanel,
                .resizable,
                .titled,
                .fullSizeContentView,
            ],
            backing: .buffered,
            defer: false
        )
        
        // Show above all other windows
        self.level = .floating
        
        // Hide the titlebar
        self.titlebarAppearsTransparent = true
        self.titlebarSeparatorStyle = .none
        
        // Allow moving by background
        self.isMovableByWindowBackground = true
        
        // Flag as partially transparent
        self.isOpaque = false
        
        // Hide window buttons
        self.standardWindowButton(.zoomButton)?.isHidden = true
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.closeButton)?.isHidden = true
        
        // Save window position
        self.setFrameAutosaveName("NotesWindow")
    }
}

extension KnotApp {
    fileprivate func addAccessoryButton() {
        let accessoryController = NSTitlebarAccessoryViewController()
        let button = NSButton(title: "Do Nothing", target: nil, action: nil)
        button.bezelStyle = .rounded
        accessoryController.view = button
        accessoryController.layoutAttribute = .right
        
        window.addTitlebarAccessoryViewController(accessoryController)
    }
    
    fileprivate func createBlurView(frame: NSRect) -> NSVisualEffectView {
        let view = NSVisualEffectView(frame: frame)
        view.material = .hudWindow
        view.blendingMode = .behindWindow
        view.state = .active
        view.autoresizingMask = [.width, .height]
        
        return view
    }
    
    fileprivate func createBackgroundView(frame: NSRect) -> NSView {
        let view = NSView(frame: frame)
        view.wantsLayer = true
        view.layer?.backgroundColor = Defaults[.color].cgColor
        view.autoresizingMask = [.width, .height]
        
        return view
    }
    
    fileprivate func createContentView() -> NSView {
        let containerView = NSView(frame: window.frame)
        containerView.wantsLayer = true
        
        // Add blur effect
        let blurView = createBlurView(frame: containerView.bounds)
        containerView.addSubview(blurView)
        
        // Add a background color
        let backgroundView = createBackgroundView(frame: containerView.bounds)
        containerView.addSubview(backgroundView)
        
        // Add scrollable text view with padding
        let scrollViewFrame = containerView.bounds.insetBy(
            dx: Defaults[.padding],
            dy: Defaults[.padding] + Defaults[.titlebarPadding] / 2
        ).applying(CGAffineTransform(translationX: 0, y: -Defaults[.titlebarPadding] / 2))
        
        let notesView = createNotesView(frame: scrollViewFrame)
        
        self.textView = notesView.documentView as? NSTextView
        
        containerView.addSubview(notesView)
        
        return containerView
    }
    
    func setupWindow() {
        // Create window
        window = NotesWindow()
        
        // Create content
        let contentView = createContentView()
        window.contentView = contentView
        
        window.makeKeyAndOrderFront(nil)
    }
    
    func updateWindow() {
        guard let window = self.window else { return }
        
        // Recreate the content view with the new padding
        let contentView = createContentView()
        window.contentView = contentView
    }
}
