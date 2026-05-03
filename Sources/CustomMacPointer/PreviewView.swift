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

        let backgroundPath = NSBezierPath(roundedRect: bounds, xRadius: 8, yRadius: 8)
        NSColor(red: 1.0, green: 0.95, blue: 0.78, alpha: 1).setFill()
        backgroundPath.fill()

        NSColor(red: 0.74, green: 0.36, blue: 0.13, alpha: 1).setStroke()
        backgroundPath.lineWidth = 2
        backgroundPath.stroke()

        guard settings.canRenderPointer else {
            let message = "No Bureks loaded"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 13, weight: .semibold),
                .foregroundColor: NSColor(red: 0.45, green: 0.25, blue: 0.12, alpha: 1)
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
}
