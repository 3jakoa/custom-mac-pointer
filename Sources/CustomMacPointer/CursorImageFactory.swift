import AppKit

enum CursorImageFactory {
    static func image(for settings: CursorSettings) -> NSImage {
        let size = max(32, min(180, settings.size))
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()

        NSGraphicsContext.current?.imageInterpolation = .high
        NSColor.clear.setFill()
        NSRect(origin: .zero, size: image.size).fill()

        if let activeImage = settings.activeImage {
            activeImage.draw(
                in: aspectFitRect(for: activeImage.size, inside: NSRect(x: 0, y: 0, width: size, height: size)),
                from: NSRect(origin: .zero, size: activeImage.size),
                operation: .sourceOver,
                fraction: 1
            )
        }

        image.unlockFocus()
        image.isTemplate = false
        return image
    }

    private static func aspectFitRect(for imageSize: NSSize, inside bounds: NSRect) -> NSRect {
        guard imageSize.width > 0, imageSize.height > 0 else {
            return bounds
        }

        let scale = min(bounds.width / imageSize.width, bounds.height / imageSize.height)
        let width = imageSize.width * scale
        let height = imageSize.height * scale

        return NSRect(
            x: bounds.midX - width / 2,
            y: bounds.midY - height / 2,
            width: width,
            height: height
        )
    }
}
