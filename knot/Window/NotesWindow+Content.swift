import Cocoa
import Defaults

extension NotesWindow {
    func createContentView() -> NSView {
        let containerView = NSView(frame: self.frame)
        containerView.wantsLayer = true

        let blurView = BlurView(frame: containerView.bounds)
        containerView.addSubview(blurView)

        let backgroundView = BackgroundView(frame: containerView.bounds)
        containerView.addSubview(backgroundView)

        let mainStackView = NSStackView()
        mainStackView.orientation = .vertical
        mainStackView.spacing = 0
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.distribution = .fill
        containerView.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(
                equalTo: containerView.topAnchor
            ),
            mainStackView.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor
            ),
            mainStackView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor
            ),
            mainStackView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor
            ),
        ])

        let titlePaddingView = NSView()
        titlePaddingView.translatesAutoresizingMaskIntoConstraints = false
        titlePaddingView.heightAnchor
            .constraint(equalToConstant: 30).isActive = true

        titlePaddingView.wantsLayer = true
        self.titlePaddingView = titlePaddingView

        let statusBarHeight: CGFloat = 30
        let statusBarView = StatusBarView(
            frame: NSRect(
                x: 0,
                y: 0,
                width: containerView.bounds.width,
                height: statusBarHeight
            )
        )
        statusBarView.translatesAutoresizingMaskIntoConstraints = false

        self.statusBarView = statusBarView
        statusBarView.heightAnchor.constraint(equalToConstant: statusBarHeight)
            .isActive = true

        let notesScrollView = NotesScrollView(frame: .zero)
        notesScrollView.translatesAutoresizingMaskIntoConstraints = false

        self.textView = notesScrollView.editableTextView

        mainStackView.addArrangedSubview(titlePaddingView)
        mainStackView.addArrangedSubview(notesScrollView)
        mainStackView.addArrangedSubview(statusBarView)

        statusBarView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor)
            .isActive = true
        notesScrollView.widthAnchor.constraint(
            equalTo: mainStackView.widthAnchor
        ).isActive = true

        updateStatusBar()

        return containerView
    }
}
