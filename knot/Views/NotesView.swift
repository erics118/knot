import SwiftUI
import Defaults

struct NotesView: View {
    @StateObject private var viewModel = NotesViewModel.shared
    @Default(.color) var backgroundColor
    @Default(.showTitle) var showTitle
    @Default(.titleBarBehavior) var titleBarBehavior
    @Default(.statusBarBehavior) var statusBarBehavior
    @Default(.showCloseButton) var showCloseButton
    
    @State private var isHovering = false
    @FocusState private var isTextFocused: Bool
    
    var body: some View {
        ZStack {
            // Background with blur effect
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()
            
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Title bar padding
                if shouldShowTitlePadding {
                    Color.clear
                        .frame(height: 30)
                        .opacity(titleBarOpacity)
                }
                
                // Text editor
                TextEditor(text: $viewModel.noteText)
                    .font(.system(size: 12, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .padding(.horizontal, 20)
                    .focused($isTextFocused)
                    .onAppear {
                        isTextFocused = true
                    }
                
                // Status bar
                if shouldShowStatusBar {
                    StatusBarView(
                        text: viewModel.statusText,
                        onTap: viewModel.toggleStatusMode
                    )
                    .frame(height: 30)
                    .opacity(statusBarOpacity)
                }
            }
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .toolbar {
            if showTitle {
                ToolbarItem(placement: .principal) {
                    Text(viewModel.windowTitle)
                        .font(.system(size: 13))
                }
            }
        }
        .navigationTitle(showTitle ? viewModel.windowTitle : "")
        .onAppear {
            configureWindow()
        }
        .keyboardShortcuts()
    }
    
    private var shouldShowTitlePadding: Bool {
        titleBarBehavior != .never
    }
    
    private var titleBarOpacity: Double {
        switch titleBarBehavior {
        case .always:
            return 1.0
        case .onHover:
            return isHovering ? 1.0 : 0.0
        case .never:
            return 0.0
        }
    }
    
    private var shouldShowStatusBar: Bool {
        statusBarBehavior != .never
    }
    
    private var statusBarOpacity: Double {
        switch statusBarBehavior {
        case .always:
            return 1.0
        case .onHover:
            return isHovering ? 1.0 : 0.0
        case .never:
            return 0.0
        }
    }
    
    private func configureWindow() {
        DispatchQueue.main.async {
            if let window = NSApp.windows.first(where: { $0.contentView != nil }) {
                window.level = .floating
                window.collectionBehavior = .canJoinAllSpaces
                window.titlebarAppearsTransparent = true
                window.titlebarSeparatorStyle = .none
                window.isMovableByWindowBackground = true
                window.isOpaque = false
                window.backgroundColor = .clear
                window.styleMask.insert(.fullSizeContentView)
                window.setFrameAutosaveName("NotesWindow")
                
                // Configure window buttons
                window.standardWindowButton(.closeButton)?.isHidden = !showCloseButton
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                window.standardWindowButton(.zoomButton)?.isHidden = true
            }
        }
    }
}

struct StatusBarView: View {
    let text: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Spacer()
                Text(text)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

// Visual Effect View for blur background
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// Keyboard shortcuts view modifier
struct KeyboardShortcutsModifier: ViewModifier {
    @ObservedObject var viewModel = NotesViewModel.shared
    
    func body(content: Content) -> some View {
        content
            .onKeyPress(.escape) {
                NSApp.keyWindow?.close()
                return .handled
            }
            .onKeyPress("w", modifiers: .command) {
                NSApp.keyWindow?.close()
                return .handled
            }
            .onKeyPress("[", modifiers: .command) {
                let currentIndex = viewModel.currentNoteIndex
                let newIndex = (currentIndex - 1 + 5) % 5
                viewModel.switchToNote(newIndex)
                return .handled
            }
            .onKeyPress("]", modifiers: .command) {
                let currentIndex = viewModel.currentNoteIndex
                let newIndex = (currentIndex + 1) % 5
                viewModel.switchToNote(newIndex)
                return .handled
            }
            .onKeyPress("1", modifiers: .command) {
                viewModel.switchToNote(0)
                return .handled
            }
            .onKeyPress("2", modifiers: .command) {
                viewModel.switchToNote(1)
                return .handled
            }
            .onKeyPress("3", modifiers: .command) {
                viewModel.switchToNote(2)
                return .handled
            }
            .onKeyPress("4", modifiers: .command) {
                viewModel.switchToNote(3)
                return .handled
            }
            .onKeyPress("5", modifiers: .command) {
                viewModel.switchToNote(4)
                return .handled
            }
    }
}

extension View {
    func keyboardShortcuts() -> some View {
        modifier(KeyboardShortcutsModifier())
    }
}
