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
        NSColor.white.setFill()
        backgroundPath.fill()

        NSColor(calibratedWhite: 0.86, alpha: 1).setStroke()
        backgroundPath.lineWidth = 1
        backgroundPath.stroke()

        guard settings.importedImage != nil else {
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
