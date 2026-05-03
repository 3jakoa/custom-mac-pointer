import AppKit

struct CursorSettings {
    var size: CGFloat = 48
    var importedImage: NSImage?

    var hotspot: CGPoint {
        CGPoint(x: size * 0.5, y: size * 0.5)
    }
}

final class AppState {
    var settings = CursorSettings() {
        didSet {
            onChange?(settings)
        }
    }

    var onChange: ((CursorSettings) -> Void)?
}
