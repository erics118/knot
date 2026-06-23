import Cocoa
import Defaults
import Markdown

private struct MarkdownLinkStyle {
    let range: SourceRange
    let destination: String
}

private struct MarkdownStyleCollector: MarkupWalker {
    var boldRanges: [SourceRange] = []
    var emphasisRanges: [SourceRange] = []
    var links: [MarkdownLinkStyle] = []

    mutating func visitHeading(_ heading: Heading) {
        if let range = heading.range {
            boldRanges.append(range)
        }
        descendInto(heading)
    }

    mutating func visitStrong(_ strong: Strong) {
        if let range = strong.range {
            boldRanges.append(range)
        }
        descendInto(strong)
    }

    mutating func visitEmphasis(_ emphasis: Emphasis) {
        if let range = emphasis.range {
            emphasisRanges.append(range)
        }
        descendInto(emphasis)
    }

    mutating func visitLink(_ link: Markdown.Link) {
        let childRanges = link.children.compactMap(\.range)
        if let destination = link.destination,
            let first = childRanges.first,
            let last = childRanges.last
        {
            links.append(
                MarkdownLinkStyle(
                    range: first.lowerBound..<last.upperBound,
                    destination: destination
                )
            )
        }
        descendInto(link)
    }
}

class EditableTextView: NSTextView {
    private var appearanceObservers: [Defaults.Observation] = []

    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
        configure()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        isRichText = false
        autoresizingMask = .width
        isVerticallyResizable = true
        maxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
        font = defaultFont
        textColor = Defaults[.textColor]
        drawsBackground = false
        isEditable = true
        isSelectable = true
        usesFontPanel = false
        wantsLayer = true
        allowsUndo = true
        textContainerInset = NSSize(width: Defaults[.padding], height: 0)
        insertionPointColor = Defaults[.caretColor]
        observeAppearanceSettings()
        //        usesAdaptiveColorMappingForDarkAppearance = true
    }

    override func becomeFirstResponder() -> Bool {
        // ColorPicker and NSTextView share the process-wide NSColorPanel. Close
        // the picker before the editor becomes first responder so AppKit cannot
        // feed the editor's foreground color back into a settings binding.
        if NSColorPanel.sharedColorPanelExists {
            NSColorPanel.shared.close()
        }
        return super.becomeFirstResponder()
    }

    override func changeColor(_ sender: Any?) {
        // Editor colors are controlled by Defaults, not AppKit's shared panel.
    }

    private var defaultFont: NSFont {
        NSFont.monospacedSystemFont(
            ofSize: Defaults[.fontSize],
            weight: .regular
        )
    }

    private func observeAppearanceSettings() {
        let stylingKeys: [Defaults.Key<NSColor>] = [
            .textColor,
            .linkColor,
        ]
        for key in stylingKeys {
            appearanceObservers.append(
                Defaults.observe(key) { [weak self] _ in
                    self?.updateEditorAppearance()
                }
            )
        }

        appearanceObservers.append(
            Defaults.observe(.fontSize) { [weak self] _ in
                self?.updateEditorAppearance()
            }
        )
        appearanceObservers.append(
            Defaults.observe(.padding) { [weak self] change in
                self?.textContainerInset = NSSize(
                    width: change.newValue,
                    height: 0
                )
            }
        )
        appearanceObservers.append(
            Defaults.observe(.caretColor) { [weak self] change in
                self?.insertionPointColor = change.newValue
                self?.needsDisplay = true
            }
        )
    }

    private func updateEditorAppearance() {
        font = defaultFont
        textColor = Defaults[.textColor]
        if !string.isEmpty {
            applyMarkdownStyling()
        }
    }

    override func didChangeText() {
        super.didChangeText()

        applyMarkdownStylingAroundSelection()
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        // Apply styling when the view is first displayed
        if window != nil && !string.isEmpty {
            applyMarkdownStyling()
        }
    }

    override var string: String {
        didSet {
            // Apply styling when text is set programmatically
            if !string.isEmpty {
                applyMarkdownStyling()
            }
        }
    }

    private func applyMarkdownStylingAroundSelection() {
        let text = string as NSString

        for value in selectedRanges {
            let selection = value.rangeValue
            let location = min(selection.location, text.length)
            let start = max(0, location - 1)
            let length = min(text.length - start, 2)
            let paragraphRange = text.paragraphRange(
                for: NSRange(location: start, length: length)
            )

            applyMarkdownStyling(in: paragraphRange)
        }
    }

    func applyMarkdownStyling() {
        applyMarkdownStyling(
            in: NSRange(location: 0, length: textStorage?.length ?? 0)
        )
    }

    private func applyMarkdownStyling(in range: NSRange) {
        guard let textStorage = self.textStorage else { return }
        guard range.length > 0 else { return }

        let source = (textStorage.string as NSString).substring(with: range)
        let document = Document(parsing: source)
        var styles = MarkdownStyleCollector()
        styles.visit(document)

        textStorage.beginEditing()
        defer { textStorage.endEditing() }

        textStorage.addAttributes(
            [
                .font: defaultFont,
                .foregroundColor: Defaults[.textColor],
            ],
            range: range
        )
        textStorage.removeAttribute(.link, range: range)
        textStorage.removeAttribute(.underlineStyle, range: range)

        for sourceRange in styles.boldRanges {
            guard
                let styleRange = nsRange(
                    for: sourceRange,
                    in: source,
                    offsetBy: range.location
                )
            else { continue }
            addFontTrait(.boldFontMask, in: styleRange, to: textStorage)
        }

        for sourceRange in styles.emphasisRanges {
            guard
                let styleRange = nsRange(
                    for: sourceRange,
                    in: source,
                    offsetBy: range.location
                )
            else { continue }
            addFontTrait(.italicFontMask, in: styleRange, to: textStorage)
        }

        for link in styles.links {
            guard
                let styleRange = nsRange(
                    for: link.range,
                    in: source,
                    offsetBy: range.location
                )
            else { continue }

            textStorage.addAttributes(
                [
                    .foregroundColor: Defaults[.linkColor],
                    .link: link.destination,
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                ],
                range: styleRange
            )
        }
    }

    private func addFontTrait(
        _ trait: NSFontTraitMask,
        in range: NSRange,
        to textStorage: NSTextStorage
    ) {
        var fonts: [(NSFont, NSRange)] = []
        textStorage.enumerateAttribute(.font, in: range) {
            value, attributeRange, _ in
            let font =
                value as? NSFont
                ?? defaultFont
            fonts.append((font, attributeRange))
        }

        for (font, attributeRange) in fonts {
            textStorage.addAttribute(
                .font,
                value: NSFontManager.shared.convert(font, toHaveTrait: trait),
                range: attributeRange
            )
        }
    }

    private func nsRange(
        for sourceRange: SourceRange,
        in source: String,
        offsetBy offset: Int
    ) -> NSRange? {
        guard
            let lowerBound = stringIndex(
                at: sourceRange.lowerBound,
                in: source
            ),
            let upperBound = stringIndex(
                at: sourceRange.upperBound,
                in: source
            )
        else { return nil }

        let range = NSRange(lowerBound..<upperBound, in: source)
        return NSRange(location: range.location + offset, length: range.length)
    }

    private func stringIndex(
        at location: SourceLocation,
        in source: String
    ) -> String.Index? {
        guard location.line > 0, location.column > 0 else { return nil }

        var line = 1
        var byteOffset = 0
        for byte in source.utf8 {
            if line == location.line { break }
            byteOffset += 1
            if byte == 0x0A { line += 1 }
        }

        guard line == location.line else { return nil }
        byteOffset += location.column - 1
        guard byteOffset <= source.utf8.count else { return nil }

        let utf8Index = source.utf8.index(
            source.utf8.startIndex,
            offsetBy: byteOffset
        )
        return String.Index(utf8Index, within: source)
    }

    override func mouseDown(with event: NSEvent) {
        if event.modifierFlags.contains(.command),
            let textStorage,
            !textStorage.string.isEmpty
        {
            let point = convert(event.locationInWindow, from: nil)

            if let characterIndex = characterIndex(at: point),
                let link = textStorage.attribute(
                    .link,
                    at: characterIndex,
                    effectiveRange: nil
                ),
                let url = linkURL(from: link)
            {
                NSWorkspace.shared.open(url)
                return
            }
        }

        super.mouseDown(with: event)
    }

    private func characterIndex(at point: NSPoint) -> Int? {
        guard let layoutManager, let textContainer else { return nil }

        let containerPoint = NSPoint(
            x: point.x - textContainerOrigin.x,
            y: point.y - textContainerOrigin.y
        )
        let glyphIndex = layoutManager.glyphIndex(
            for: containerPoint,
            in: textContainer
        )
        guard glyphIndex < layoutManager.numberOfGlyphs else { return nil }
        let glyphRange = NSRange(location: glyphIndex, length: 1)
        guard
            layoutManager.boundingRect(
                forGlyphRange: glyphRange,
                in: textContainer
            ).contains(containerPoint)
        else { return nil }

        return layoutManager.characterIndexForGlyph(at: glyphIndex)
    }

    private func linkURL(from value: Any) -> URL? {
        if let url = value as? URL {
            return url
        }
        if let string = value as? String {
            return URL(string: string)
        }
        return nil
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let modifierFlags = event.modifierFlags.intersection(
            .deviceIndependentFlagsMask
        )

        // Helpers
        func switchNote(_ idx: Int) {
            guard let win = window as? NotesWindow else { return }
            win.switchToNote(idx)
        }
        func prevNote() {
            let i = Defaults[.currentNoteIndex]
            switchNote((i - 1 + 5) % 5)
        }
        func nextNote() {
            let i = Defaults[.currentNoteIndex]
            switchNote((i + 1) % 5)
        }

        // Command key shortcuts
        if modifierFlags == .command {
            switch event.keyCode {
            case 0x00:  // Cmd+A (Select All)
                selectAll(nil)
                return true
            case 0x06:  // Cmd+Z (Undo)
                undoManager?.undo()
                if let win = window as? NotesWindow {
                    win.saveCurrentNote()
                }
                return true
            case 0x07:  // Cmd+X (Cut)
                cut(nil)
                // Trigger autosave after cut
                if let win = window as? NotesWindow {
                    win.saveCurrentNote()
                }
                return true
            case 0x08:  // Cmd+C (Copy)
                copy(nil)
                return true
            case 0x09:  // Cmd+V (Paste)
                paste(nil)
                // Trigger autosave after paste
                if let win = window as? NotesWindow {
                    win.saveCurrentNote()
                }
                return true
            case 0x0D:  // Cmd+W (Close Window)
                NSApp.keyWindow?.close()
                return true
            case 0x10:  // Cmd+Y (Redo)
                undoManager?.redo()
                // Trigger autosave after redo
                if let win = window as? NotesWindow {
                    win.saveCurrentNote()
                }
                return true
            case 0x21:  // Cmd+[ (Previous Note)
                prevNote()
                return true
            case 0x1E:  // Cmd+] (Next Note)
                nextNote()
                return true
            default:
                // Handle Cmd+1 through Cmd+9
                if let ch = event.charactersIgnoringModifiers?.first,
                    let n = ch.wholeNumberValue, (1...5).contains(n)
                {
                    switchNote(n - 1)
                    return true
                }
                return false
            }
        }

        return super.performKeyEquivalent(with: event)
    }
}
