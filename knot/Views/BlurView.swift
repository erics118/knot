import Cocoa

final class BlurView: NSVisualEffectView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        material = .hudWindow
        blendingMode = .behindWindow
        state = .active
        autoresizingMask = [.width, .height]
    }
}
