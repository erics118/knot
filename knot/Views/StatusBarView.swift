import Cocoa
import Defaults

final class StatusBarView: NSView {
    var showCharacterCountObserver: Defaults.Observation?
    private var fontSizeObserver: Defaults.Observation?
    private var textColorObserver: Defaults.Observation?

    var charCount: Int = 0
    var wordCount: Int = 0

    func setTitle(_ title: String) {
        statusButton.attributedTitle = NSAttributedString(
            string: title,
            attributes: [
                .font: NSFont.monospacedSystemFont(
                    ofSize: Defaults[.fontSize],
                    weight: .regular
                ),
                .foregroundColor: Defaults[.textColor]
                    .withAlphaComponent(0.5),
            ]
        )
    }

    func updateText() {
        if Defaults[.showCharacterCount] {
            let characterString = charCount == 1 ? "character" : "characters"
            setTitle("\(charCount) \(characterString)")
        } else {
            let wordString = wordCount == 1 ? "word" : "words"
            setTitle("\(wordCount) \(wordString)")
        }
    }

    func updateCount(from text: String) {
        charCount = text.count
        wordCount = text.split { $0.isWhitespace || $0.isNewline }.count
        updateText()
    }

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
        updateText()
        statusButton.translatesAutoresizingMaskIntoConstraints = true
        addSubview(statusButton)

        showCharacterCountObserver = Defaults.observe(.showCharacterCount) {
            [weak self] _ in
            self?.updateText()
        }
        fontSizeObserver = Defaults.observe(.fontSize) { [weak self] _ in
            self?.updateText()
        }
        textColorObserver = Defaults.observe(.textColor) { [weak self] _ in
            self?.updateText()
        }
    }

    @objc private func handleToggle() {
        Defaults[.showCharacterCount].toggle()
    }
}
