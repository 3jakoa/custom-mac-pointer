import AppKit

final class CursorPreviewView: NSView {
    var settings = CursorSettings() {
        didSet {
            needsDisplay = true
        }
    }

    override var isFlipped: Bool {
        true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let backgroundPath = NSBezierPath(roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5), xRadius: 12, yRadius: 12)

        NSGraphicsContext.saveGraphicsState()
        backgroundPath.addClip()
        NSGradient(starting: Design.creamMid, ending: Design.creamDark)?.draw(in: bounds, angle: -55)
        drawTopHighlight()
        NSGraphicsContext.restoreGraphicsState()

        NSColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 0.5).setStroke()
        NSBezierPath.strokeLine(from: CGPoint(x: 1, y: bounds.height - 1.5), to: CGPoint(x: bounds.width - 1, y: bounds.height - 1.5))

        NSColor(red: 120 / 255, green: 80 / 255, blue: 20 / 255, alpha: 0.07).setStroke()
        let innerPath = NSBezierPath(roundedRect: bounds.insetBy(dx: 2, dy: 2), xRadius: 10, yRadius: 10)
        innerPath.lineWidth = 3
        innerPath.stroke()

        NSColor(red: 180 / 255, green: 130 / 255, blue: 60 / 255, alpha: 0.2).setStroke()
        backgroundPath.lineWidth = 1
        backgroundPath.stroke()

        let label = "cursor preview"
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 10),
            .foregroundColor: NSColor(red: 120 / 255, green: 80 / 255, blue: 20 / 255, alpha: 0.45),
            .obliqueness: 0.14
        ]
        let labelSize = label.size(withAttributes: labelAttributes)
        label.draw(
            at: CGPoint(x: bounds.width - labelSize.width - 11, y: bounds.height - labelSize.height - 9),
            withAttributes: labelAttributes
        )

        guard settings.canRenderPointer else {
            let message = "No Bureks loaded"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 13, weight: .medium),
                .foregroundColor: Design.brownMid
            ]
            let size = message.size(withAttributes: attributes)
            message.draw(
                at: CGPoint(x: bounds.midX - size.width / 2, y: bounds.midY - size.height / 2),
                withAttributes: attributes
            )
            return
        }

        let image = CursorImageFactory.image(for: settings)
        let imageRect = NSRect(
            x: bounds.midX - image.size.width / 2,
            y: bounds.midY - image.size.height / 2,
            width: image.size.width,
            height: image.size.height
        )
        image.draw(in: imageRect)
    }

    private func drawTopHighlight() {
        guard let context = NSGraphicsContext.current?.cgContext,
              let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    NSColor.white.withAlphaComponent(0.22).cgColor,
                    NSColor.white.withAlphaComponent(0).cgColor
                ] as CFArray,
                locations: [0, 1]
              ) else {
            return
        }

        context.drawRadialGradient(
            gradient,
            startCenter: CGPoint(x: bounds.midX, y: 0),
            startRadius: 0,
            endCenter: CGPoint(x: bounds.midX, y: 0),
            endRadius: bounds.width * 0.62,
            options: [.drawsAfterEndLocation]
        )
    }
}
