import Cocoa
import Defaults

final class BackgroundView: NSView {
    private var colorObserver: Defaults.Observation?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        wantsLayer = true
        layer?.backgroundColor = Defaults[.color].cgColor
        autoresizingMask = [.width, .height]

        colorObserver = Defaults.observe(.color) { [weak self] change in
            self?.layer?.backgroundColor = change.newValue.cgColor
        }

    }
}
