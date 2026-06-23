import Cocoa
import Defaults
import KeyboardShortcuts
import SwiftUI

struct GeneralSettingsView: View {
    @Default(.shortcutBehavior) var shortcutBehavior
    @Default(.showCloseButton) var showCloseButton
    @Default(.showTitle) var showTitle
    @Default(.closeOnEscape) var closeOnEscape
    @Default(.titleBarBehavior) var titleBarBehavior
    @Default(.statusBarBehavior) var statusBarBehavior

    var body: some View {
        Form {
            Section("Shortcut") {
                KeyboardShortcuts.Recorder(
                    "Global Shortcut",
                    name: .toggleFloatingNote
                )

                Picker("Behavior", selection: $shortcutBehavior) {
                    ForEach(ShortcutBehavior.allCases) { option in
                        Text(option.displayName).tag(option)
                    }
                }
            }

            Section("Window") {
                Toggle("Close with Escape", isOn: $closeOnEscape)
            }

            Section("Title Bar") {
                Picker("Visibility", selection: $titleBarBehavior) {
                    ForEach(VisibilityBehavior.allCases, id: \.self) {
                        behavior in
                        Text(behavior.displayName).tag(behavior)
                    }
                }

                LabeledContent("Show") {
                    Toggle("Window Buttons", isOn: $showCloseButton)
                        .toggleStyle(.button)
                    Toggle("Title", isOn: $showTitle)
                        .toggleStyle(.button)
                }
            }

            Section("Status Bar") {
                Picker("Visibility", selection: $statusBarBehavior) {
                    ForEach(VisibilityBehavior.allCases, id: \.self) {
                        behavior in
                        Text(behavior.displayName).tag(behavior)
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}

struct AppearanceSettingsView: View {
    @Default(.color) var color
    @Default(.fontSize) var fontSize
    @Default(.padding) var padding
    @Default(.textColor) var textColor
    @Default(.linkColor) var linkColor
    @Default(.caretColor) var caretColor

    private func colorBinding(_ binding: Binding<NSColor>) -> Binding<Color> {
        Binding(
            get: { Color(nsColor: binding.wrappedValue) },
            set: { binding.wrappedValue = NSColor($0) }
        )
    }

    var body: some View {
        Form {
            Section("Editor") {
                LabeledContent("Font Size") {
                    HStack {
                        Slider(value: $fontSize, in: 9...24, step: 1)
                        Text("\(Int(fontSize)) pt")
                            .monospacedDigit()
                            .frame(width: 40, alignment: .trailing)
                    }
                }

                LabeledContent("Horizontal Padding") {
                    HStack {
                        Slider(value: $padding, in: 0...60, step: 1)
                        Text("\(Int(padding)) pt")
                            .monospacedDigit()
                            .frame(width: 40, alignment: .trailing)
                    }
                }

                ColorPicker(
                    "Text Color",
                    selection: colorBinding($textColor),
                    supportsOpacity: false
                )
                ColorPicker(
                    "Link Color",
                    selection: colorBinding($linkColor),
                    supportsOpacity: false
                )
                ColorPicker(
                    "Caret Color",
                    selection: colorBinding($caretColor),
                    supportsOpacity: false
                )
            }

            Section("Background") {
                ColorPicker(
                    "Background Color and Opacity",
                    selection: $color,
                    supportsOpacity: true
                )
            }
        }
        .formStyle(.grouped)
    }
}

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            AppearanceSettingsView()
                .tabItem {
                    Label("Appearance", systemImage: "paintpalette")
                }
        }
        .scenePadding()
    }
}

class SettingsWindowController: NSWindowController {
    private var hostingController: NSHostingController<SettingsView>?

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 0, height: 0),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "knot Settings"

        let settingsView = SettingsView()
        let hostingController = NSHostingController(rootView: settingsView)

        // Set content view controller
        window.contentViewController = hostingController

        // Size window to fit content
        window.setContentSize(hostingController.view.fittingSize)

        // Allow the window to resize to fit content
        window.contentMinSize = NSSize(width: 600, height: 400)
        window.contentMaxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )

        // Hide the titlebar
        window.titlebarAppearsTransparent = true
        window.titlebarSeparatorStyle = .none

        window.setFrameAutosaveName("SettingsWindow")
        window.isMovableByWindowBackground = true

        self.init(window: window)

        // Store reference to hosting controller
        self.hostingController = hostingController
    }
}
