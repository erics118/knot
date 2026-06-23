import Cocoa
import Defaults
import SwiftUI

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
        layer?.backgroundColor = NSColor(Defaults[.color]).cgColor
        autoresizingMask = [.width, .height]

        colorObserver = Defaults.observe(.color) { [weak self] change in
            self?.layer?.backgroundColor = NSColor(change.newValue).cgColor
        }

    }
}
