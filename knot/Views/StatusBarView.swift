import Cocoa
import Defaults

final class StatusBarView: NSView {
    var statusBarBehaviorObserver: Defaults.Observation?

    func setTitle(_ title: String) {
        statusButton.title = title
    }

    func updateCount(from text: String) {
        let charCount = text.count
        let wordCount = text.split { $0.isWhitespace || $0.isNewline }.count
        if Defaults[.showCharacterCount] {
            let characterString = charCount == 1 ? "character" : "characters"
            setTitle("\(charCount) \(characterString)")
        } else {
            let wordString = wordCount == 1 ? "word" : "words"
            setTitle("\(wordCount) \(wordString)")
        }
    }

    func applyOpacityBehavior() {
        switch Defaults[.statusBarBehavior] {
        case .always:
            alphaValue = 1.0
        case .onHover:
            alphaValue = 0.0
        case .never:
            alphaValue = 0.0
        }
    }

    var onToggle: (() -> Void)?

    private let statusButton: NSButton

    override init(frame frameRect: NSRect) {
        self.statusButton = NSButton(frame: frameRect)
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        self.statusButton = NSButton(frame: .zero)
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        wantsLayer = true
        autoresizingMask = [.width, .minYMargin]

        // Configure button
        statusButton.bezelStyle = .regularSquare
        statusButton.isBordered = false
        statusButton.title = ""
        statusButton.target = self
        statusButton.action = #selector(handleToggle)
        statusButton.autoresizingMask = [.width, .height]
        statusButton.alignment = .center
        statusButton.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        statusButton.contentTintColor = .tertiaryLabelColor
        statusButton.translatesAutoresizingMaskIntoConstraints = true
        addSubview(statusButton)

        statusBarBehaviorObserver = Defaults.observe(.statusBarBehavior) {
            [weak self] _ in
            self?.applyOpacityBehavior()
        }
    }

    @objc private func handleToggle() {
        onToggle?()
    }
}
