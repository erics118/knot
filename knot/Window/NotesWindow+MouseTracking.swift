import Cocoa
import Defaults

extension NotesWindow {
    func setupMouseTracking() {
        let options: NSTrackingArea.Options = [
            .mouseEnteredAndExited, .activeAlways, .inVisibleRect,
        ]
        trackingArea = NSTrackingArea(
            rect: .zero,
            options: options,
            owner: self,
            userInfo: nil
        )
        contentView?.addTrackingArea(trackingArea!)
    }

    override public func mouseEntered(with event: NSEvent) {
        if Defaults[.titleBarBehavior] == .onHover {
            if let titlebarView = self.standardWindowButton(.closeButton)?
                .superview
            {
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.2
                    context.timingFunction = CAMediaTimingFunction(
                        name: .easeInEaseOut
                    )
                    titlebarView.animator().alphaValue = 1.0
                    titlePaddingView?.animator().alphaValue = 1.0
                }
            }
        }

        if Defaults[.statusBarBehavior] == .onHover {
            if let statusBar = self.statusBarView {
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.2
                    context.timingFunction = CAMediaTimingFunction(
                        name: .easeInEaseOut
                    )
                    statusBar.animator().alphaValue = 1.0
                }
            }
        }
    }

    override public func mouseExited(with event: NSEvent) {
        if Defaults[.titleBarBehavior] == .onHover {
            if let titlebarView = self.standardWindowButton(.closeButton)?
                .superview
            {
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.2
                    context.timingFunction = CAMediaTimingFunction(
                        name: .easeInEaseOut
                    )
                    titlebarView.animator().alphaValue = 0.0
                    titlePaddingView?.animator().alphaValue = 0.0
                }
            }
        }

        if Defaults[.statusBarBehavior] == .onHover {
            if let statusBar = self.statusBarView {
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.2
                    context.timingFunction = CAMediaTimingFunction(
                        name: .easeInEaseOut
                    )
                    statusBar.animator().alphaValue = 0.0
                }
            }
        }
    }
}
