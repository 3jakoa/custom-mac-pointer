import AppKit

enum Design {
    static let cream = NSColor(hex: 0xfdf6e8)
    static let creamMid = NSColor(hex: 0xf5e8c4)
    static let creamDark = NSColor(hex: 0xecdaa6)
    static let brown = NSColor(hex: 0x3d1f0a)
    static let brownMid = NSColor(hex: 0x6b4520)
    static let brownLight = NSColor(hex: 0x7a4a20)
    static let gold = NSColor(hex: 0xc8a040)
    static let goldMid = NSColor(hex: 0xb06020)
    static let amber = NSColor(hex: 0xb87030)
    static let muted = NSColor(hex: 0x9a6e42)
    static let mutedButton = NSColor(hex: 0x9a7040)
    static let statusText = NSColor(hex: 0xa07840)
    static let primaryDark = NSColor(hex: 0x5a2e12)
    static let primaryMid = NSColor(hex: 0x7a3e22)
    static let primaryText = NSColor(hex: 0xfde8be)
    static let green = NSColor(hex: 0x3a9a52)
    static let divider = NSColor(red: 180 / 255, green: 130 / 255, blue: 60 / 255, alpha: 0.15)

    static func displayFont(size: CGFloat, weight: NSFont.Weight) -> NSFont {
        let traits: NSFontTraitMask = weight == .bold || weight == .heavy ? .boldFontMask : []
        return NSFontManager.shared.font(
            withFamily: "New York",
            traits: traits,
            weight: 9,
            size: size
        ) ?? .systemFont(ofSize: size, weight: weight)
    }
}

extension NSColor {
    convenience init(hex: Int, alpha: CGFloat = 1) {
        self.init(
            srgbRed: CGFloat((hex >> 16) & 0xff) / 255,
            green: CGFloat((hex >> 8) & 0xff) / 255,
            blue: CGFloat(hex & 0xff) / 255,
            alpha: alpha
        )
    }
}

class SectionView: NSView {
    var borderTop = false
    var borderBottom = false
    var borderAlpha: CGFloat = 0.15

    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        Design.cream.setFill()
        bounds.fill()

        let borderColor = NSColor(
            red: 180 / 255,
            green: 130 / 255,
            blue: 60 / 255,
            alpha: borderAlpha
        )
        borderColor.setStroke()

        if borderTop {
            NSBezierPath.strokeLine(
                from: CGPoint(x: 0, y: 0.5),
                to: CGPoint(x: bounds.width, y: 0.5)
            )
        }

        if borderBottom {
            NSBezierPath.strokeLine(
                from: CGPoint(x: 0, y: bounds.height - 0.5),
                to: CGPoint(x: bounds.width, y: bounds.height - 0.5)
            )
        }
    }
}

final class AppHeaderView: SectionView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        borderBottom = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let title = "Burek Cursor"
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: Design.displayFont(size: 24, weight: .bold),
            .foregroundColor: Design.brown
        ]
        title.draw(at: CGPoint(x: 24, y: 22), withAttributes: titleAttributes)

        let tagline = "freshly baked cursor chaos"
        let taglineAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12.5),
            .foregroundColor: Design.muted,
            .obliqueness: 0.14
        ]
        tagline.draw(at: CGPoint(x: 24, y: 51), withAttributes: taglineAttributes)
    }
}

final class StatusChipView: NSView {
    private let textField = NSTextField(labelWithString: "")

    var text = "" {
        didSet {
            textField.stringValue = text
        }
    }

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer?.backgroundColor = NSColor(red: 210 / 255, green: 175 / 255, blue: 100 / 255, alpha: 0.15).cgColor
        layer?.borderColor = NSColor(red: 180 / 255, green: 130 / 255, blue: 60 / 255, alpha: 0.22).cgColor
        layer?.borderWidth = 1
        layer?.cornerRadius = 12.5

        let dot = NSView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.wantsLayer = true
        dot.layer?.backgroundColor = Design.green.cgColor
        dot.layer?.cornerRadius = 3.5
        dot.layer?.shadowColor = Design.green.cgColor
        dot.layer?.shadowOpacity = 0.2
        dot.layer?.shadowRadius = 2
        dot.layer?.shadowOffset = .zero

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: 12, weight: .medium)
        textField.textColor = Design.brownLight
        textField.lineBreakMode = .byTruncatingTail
        textField.maximumNumberOfLines = 1

        addSubview(dot)
        addSubview(textField)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 25),
            dot.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            dot.centerYAnchor.constraint(equalTo: centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 7),
            dot.heightAnchor.constraint(equalToConstant: 7),
            textField.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 7),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class StatusLineView: NSView {
    private let label = NSTextField(labelWithString: "")

    var text = "" {
        didSet {
            label.stringValue = text
        }
    }

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let dot = NSView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.wantsLayer = true
        dot.layer?.backgroundColor = Design.green.cgColor
        dot.layer?.cornerRadius = 2.5

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = Design.statusText
        label.alignment = .center
        label.lineBreakMode = .byTruncatingTail

        addSubview(dot)
        addSubview(label)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 15),
            dot.centerYAnchor.constraint(equalTo: centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 5),
            dot.heightAnchor.constraint(equalToConstant: 5),
            label.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 6),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            dot.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            label.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 5.5)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class BurekSizeSlider: NSControl {
    var minValue: CGFloat = 20
    var maxValue: CGFloat = 250
    var value: CGFloat = 106 {
        didSet {
            value = max(minValue, min(maxValue, value))
            needsDisplay = true
        }
    }

    override var intrinsicContentSize: NSSize {
        NSSize(width: NSView.noIntrinsicMetric, height: 24)
    }

    override var acceptsFirstResponder: Bool { true }

    override func becomeFirstResponder() -> Bool {
        needsDisplay = true
        return true
    }

    override func resignFirstResponder() -> Bool {
        needsDisplay = true
        return true
    }

    override func draw(_ dirtyRect: NSRect) {
        let trackRect = NSRect(x: 9, y: bounds.midY - 2.5, width: max(0, bounds.width - 18), height: 5)
        let radius: CGFloat = 2.5
        let progress = (value - minValue) / (maxValue - minValue)
        let fillWidth = trackRect.width * progress

        NSColor(red: 180 / 255, green: 130 / 255, blue: 60 / 255, alpha: 0.2).setFill()
        NSBezierPath(roundedRect: trackRect, xRadius: radius, yRadius: radius).fill()

        if fillWidth > 0 {
            let fillRect = NSRect(x: trackRect.minX, y: trackRect.minY, width: fillWidth, height: trackRect.height)
            NSGraphicsContext.saveGraphicsState()
            NSBezierPath(roundedRect: fillRect, xRadius: radius, yRadius: radius).addClip()
            NSGradient(starting: Design.gold, ending: Design.goldMid)?.draw(in: fillRect, angle: 0)
            NSGraphicsContext.restoreGraphicsState()
        }

        let thumbCenter = CGPoint(x: trackRect.minX + fillWidth, y: bounds.midY)
        let shadow = NSShadow()
        shadow.shadowColor = NSColor(red: 74 / 255, green: 30 / 255, blue: 10 / 255, alpha: 0.22)
        shadow.shadowBlurRadius = 6
        shadow.shadowOffset = NSSize(width: 0, height: -2)

        NSGraphicsContext.saveGraphicsState()
        shadow.set()
        NSColor.white.setFill()
        NSBezierPath(ovalIn: NSRect(x: thumbCenter.x - 9, y: thumbCenter.y - 9, width: 18, height: 18)).fill()
        NSGraphicsContext.restoreGraphicsState()

        Design.amber.setStroke()
        let thumbPath = NSBezierPath(ovalIn: NSRect(x: thumbCenter.x - 9, y: thumbCenter.y - 9, width: 18, height: 18))
        thumbPath.lineWidth = 2
        thumbPath.stroke()

        if window?.firstResponder === self {
            NSColor.keyboardFocusIndicatorColor.setStroke()
            let focusPath = NSBezierPath(roundedRect: bounds.insetBy(dx: 1.5, dy: 1.5), xRadius: 6, yRadius: 6)
            focusPath.lineWidth = 2
            focusPath.stroke()
        }
    }

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        updateValue(with: event)
    }

    override func mouseDragged(with event: NSEvent) {
        updateValue(with: event)
    }

    private func updateValue(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        let trackWidth = max(1, bounds.width - 18)
        let progress = max(0, min(1, (location.x - 9) / trackWidth))
        value = (minValue + progress * (maxValue - minValue)).rounded()
        sendAction(action, to: target)
    }

    override func keyDown(with event: NSEvent) {
        let step: CGFloat = event.modifierFlags.contains(.shift) ? 10 : 1
        switch event.keyCode {
        case 124, 126:
            increment(by: step)
        case 123, 125:
            increment(by: -step)
        case 115:
            setValueAndNotify(minValue)
        case 119:
            setValueAndNotify(maxValue)
        default:
            super.keyDown(with: event)
        }
    }

    private func increment(by delta: CGFloat) {
        setValueAndNotify(value + delta)
    }

    private func setValueAndNotify(_ newValue: CGFloat) {
        value = newValue.rounded()
        sendAction(action, to: target)
    }

    override func isAccessibilityElement() -> Bool {
        true
    }

    override func accessibilityRole() -> NSAccessibility.Role? {
        .slider
    }

    override func accessibilityLabel() -> String? {
        "Burek size"
    }

    override func accessibilityValue() -> Any? {
        Int(value.rounded())
    }

    override func accessibilityMinValue() -> Any? {
        Int(minValue.rounded())
    }

    override func accessibilityMaxValue() -> Any? {
        Int(maxValue.rounded())
    }

    override func accessibilityPerformIncrement() -> Bool {
        increment(by: 1)
        return true
    }

    override func accessibilityPerformDecrement() -> Bool {
        increment(by: -1)
        return true
    }
}

final class BurekModeControl: NSControl {
    var mode: CursorMode = .floating {
        didSet {
            needsDisplay = true
        }
    }

    override var intrinsicContentSize: NSSize {
        NSSize(width: NSView.noIntrinsicMetric, height: 30)
    }

    override var acceptsFirstResponder: Bool { true }

    override func becomeFirstResponder() -> Bool {
        needsDisplay = true
        return true
    }

    override func resignFirstResponder() -> Bool {
        needsDisplay = true
        return true
    }

    override func draw(_ dirtyRect: NSRect) {
        let track = bounds.insetBy(dx: 0, dy: 0)
        NSColor(red: 180 / 255, green: 130 / 255, blue: 60 / 255, alpha: 0.14).setFill()
        NSBezierPath(roundedRect: track, xRadius: 9, yRadius: 9).fill()

        let optionWidth = (bounds.width - 8) / 2
        let activeX = mode == .floating ? 3 : 5 + optionWidth
        let activeRect = NSRect(x: activeX, y: 3, width: optionWidth, height: bounds.height - 6)
        let shadow = NSShadow()
        shadow.shadowColor = NSColor(red: 74 / 255, green: 30 / 255, blue: 10 / 255, alpha: 0.12)
        shadow.shadowBlurRadius = 4
        shadow.shadowOffset = NSSize(width: 0, height: -1)

        NSGraphicsContext.saveGraphicsState()
        shadow.set()
        NSColor.white.setFill()
        NSBezierPath(roundedRect: activeRect, xRadius: 7, yRadius: 7).fill()
        NSGraphicsContext.restoreGraphicsState()

        NSColor(red: 180 / 255, green: 130 / 255, blue: 60 / 255, alpha: 0.25).setStroke()
        NSBezierPath(roundedRect: activeRect, xRadius: 7, yRadius: 7).stroke()

        drawOption("Floating", in: NSRect(x: 3, y: 0, width: optionWidth, height: bounds.height), active: mode == .floating)
        drawOption("Pointer", in: NSRect(x: 5 + optionWidth, y: 0, width: optionWidth, height: bounds.height), active: mode == .pointer)

        if window?.firstResponder === self {
            NSColor.keyboardFocusIndicatorColor.setStroke()
            let focusPath = NSBezierPath(roundedRect: bounds.insetBy(dx: 1.5, dy: 1.5), xRadius: 9, yRadius: 9)
            focusPath.lineWidth = 2
            focusPath.stroke()
        }
    }

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        let location = convert(event.locationInWindow, from: nil)
        mode = location.x > bounds.midX ? .pointer : .floating
        sendAction(action, to: target)
    }

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 123, 126:
            setModeAndNotify(.floating)
        case 124, 125:
            setModeAndNotify(.pointer)
        default:
            switch event.charactersIgnoringModifiers {
            case " ", "\r":
                setModeAndNotify(mode == .floating ? .pointer : .floating)
            default:
                super.keyDown(with: event)
            }
        }
    }

    private func setModeAndNotify(_ newMode: CursorMode) {
        guard mode != newMode else { return }
        mode = newMode
        sendAction(action, to: target)
    }

    override func isAccessibilityElement() -> Bool {
        true
    }

    override func accessibilityRole() -> NSAccessibility.Role? {
        .radioGroup
    }

    override func accessibilityLabel() -> String? {
        "Mode"
    }

    override func accessibilityValue() -> Any? {
        mode == .floating ? "Floating" : "Pointer"
    }

    override func accessibilityPerformPress() -> Bool {
        setModeAndNotify(mode == .floating ? .pointer : .floating)
        return true
    }

    private func drawOption(_ text: String, in rect: NSRect, active: Bool) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13, weight: active ? .semibold : .medium),
            .foregroundColor: active ? Design.brown : NSColor(hex: 0x9a6840)
        ]
        let size = text.size(withAttributes: attributes)
        text.draw(
            at: CGPoint(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2),
            withAttributes: attributes
        )
    }
}

final class BurekButton: NSControl {
    enum Style {
        case ghost
        case primary
    }

    let title: String
    let style: Style
    private var isHovering = false
    private var isPressing = false
    private var trackingArea: NSTrackingArea?

    init(title: String, style: Style) {
        self.title = title
        self.style = style
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: NSSize {
        NSSize(width: NSView.noIntrinsicMetric, height: 38)
    }

    override var acceptsFirstResponder: Bool { true }

    override var isEnabled: Bool {
        didSet {
            needsDisplay = true
        }
    }

    override func becomeFirstResponder() -> Bool {
        needsDisplay = true
        return true
    }

    override func resignFirstResponder() -> Bool {
        needsDisplay = true
        return true
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea {
            removeTrackingArea(trackingArea)
        }

        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self
        )
        addTrackingArea(area)
        trackingArea = area
    }

    override func mouseEntered(with event: NSEvent) {
        isHovering = true
        needsDisplay = true
    }

    override func mouseExited(with event: NSEvent) {
        isHovering = false
        isPressing = false
        needsDisplay = true
    }

    override func mouseDown(with event: NSEvent) {
        guard isEnabled else { return }
        window?.makeFirstResponder(self)
        isPressing = true
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        guard isEnabled else { return }
        let inside = bounds.contains(convert(event.locationInWindow, from: nil))
        isPressing = false
        needsDisplay = true
        if inside {
            sendAction(action, to: target)
        }
    }

    override func keyDown(with event: NSEvent) {
        guard isEnabled, let characters = event.charactersIgnoringModifiers else {
            super.keyDown(with: event)
            return
        }

        switch characters {
        case " ", "\r":
            sendAction(action, to: target)
        default:
            super.keyDown(with: event)
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        let rect = bounds.insetBy(dx: 0.5, dy: 0.5)
        let path = NSBezierPath(roundedRect: rect, xRadius: 9, yRadius: 9)
        let alpha: CGFloat = isEnabled ? 1 : 0.42

        switch style {
        case .ghost:
            let fillAlpha: CGFloat = isHovering && isEnabled ? 0.18 : 0.10
            NSColor(red: 180 / 255, green: 130 / 255, blue: 60 / 255, alpha: fillAlpha * alpha).setFill()
            path.fill()
            NSColor(red: 180 / 255, green: 130 / 255, blue: 60 / 255, alpha: 0.22 * alpha).setStroke()
            path.lineWidth = 1
            path.stroke()
        case .primary:
            NSGraphicsContext.saveGraphicsState()
            path.addClip()
            let start = isHovering && isEnabled ? NSColor(hex: 0x6a3618, alpha: alpha) : Design.primaryDark.withAlphaComponent(alpha)
            let end = isHovering && isEnabled ? NSColor(hex: 0x8a4a28, alpha: alpha) : Design.primaryMid.withAlphaComponent(alpha)
            NSGradient(starting: start, ending: end)?.draw(in: rect, angle: -70)
            NSGraphicsContext.restoreGraphicsState()

            if isEnabled {
                let shadow = NSShadow()
                shadow.shadowColor = NSColor(red: 74 / 255, green: 30 / 255, blue: 10 / 255, alpha: isHovering ? 0.35 : 0.3)
                shadow.shadowBlurRadius = isHovering ? 14 : 8
                shadow.shadowOffset = NSSize(width: 0, height: -2)
                NSGraphicsContext.saveGraphicsState()
                shadow.set()
                path.stroke()
                NSGraphicsContext.restoreGraphicsState()
            }
        }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13.5, weight: .semibold),
            .foregroundColor: textColor.withAlphaComponent(alpha)
        ]
        let textSize = title.size(withAttributes: attributes)
        let yOffset: CGFloat = isPressing ? 1 : 0
        title.draw(
            at: CGPoint(x: rect.midX - textSize.width / 2, y: rect.midY - textSize.height / 2 + yOffset),
            withAttributes: attributes
        )

        if window?.firstResponder === self {
            NSColor.keyboardFocusIndicatorColor.setStroke()
            let focusPath = NSBezierPath(roundedRect: rect.insetBy(dx: 2, dy: 2), xRadius: 7, yRadius: 7)
            focusPath.lineWidth = 2
            focusPath.stroke()
        }
    }

    private var textColor: NSColor {
        switch style {
        case .ghost:
            return Design.mutedButton
        case .primary:
            return Design.primaryText
        }
    }

    override func isAccessibilityElement() -> Bool {
        true
    }

    override func accessibilityRole() -> NSAccessibility.Role? {
        .button
    }

    override func accessibilityLabel() -> String? {
        title
    }

    override func accessibilityPerformPress() -> Bool {
        guard isEnabled else { return false }
        sendAction(action, to: target)
        return true
    }
}
