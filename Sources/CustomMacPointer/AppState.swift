import AppKit

struct CursorArtwork {
    let name: String
    let image: NSImage
}

enum CursorMode {
    case floating
    case pointer
}

struct CursorSettings {
    var size: CGFloat = 106
    var mode: CursorMode = .floating
    var boreks: [CursorArtwork] = []
    var activeBorekIndex = 0

    var hotspot: CGPoint {
        CGPoint(x: size * 0.5, y: size * 0.5)
    }

    var activeBorek: CursorArtwork? {
        guard !boreks.isEmpty else { return nil }
        return boreks[activeBorekIndex % boreks.count]
    }

    var activeImage: NSImage? {
        activeBorek?.image
    }

    var canRenderPointer: Bool {
        activeImage != nil
    }
}

final class AppState {
    var settings = CursorSettings() {
        didSet {
            onChange?(settings)
        }
    }

    var onChange: ((CursorSettings) -> Void)?

    init(boreks: [CursorArtwork] = []) {
        settings.boreks = boreks
    }

    func advanceBorek() {
        guard !settings.boreks.isEmpty else { return }
        var updated = settings
        updated.activeBorekIndex = (settings.activeBorekIndex + 1) % settings.boreks.count
        settings = updated
    }
}
