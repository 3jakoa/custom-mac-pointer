import AppKit
import CoreGraphics

@MainActor
final class CursorOverlayController {
    private let panel: NSPanel
    private let imageView: NSImageView
    private var timer: Timer?
    private var settings = CursorSettings()
    private var isCursorHidden = false

    var isRunning: Bool {
        timer != nil
    }

    init() {
        imageView = NSImageView(frame: NSRect(x: 0, y: 0, width: settings.size, height: settings.size))
        imageView.imageScaling = .scaleProportionallyUpOrDown

        panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: settings.size, height: settings.size),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.ignoresMouseEvents = true
        panel.level = .screenSaver
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        panel.contentView = imageView

        update(settings: settings)
    }

    func update(settings: CursorSettings) {
        self.settings = settings
        let image = CursorImageFactory.image(for: settings)
        let size = image.size

        imageView.image = image
        imageView.frame = NSRect(origin: .zero, size: size)
        panel.setContentSize(size)

        if isRunning {
            positionPanel()
        }
    }

    func start() {
        guard timer == nil else { return }
        hideSystemCursor()
        panel.orderFrontRegardless()
        positionPanel()

        timer = Timer.scheduledTimer(
            timeInterval: 1.0 / 120.0,
            target: self,
            selector: #selector(timerFired),
            userInfo: nil,
            repeats: true
        )
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        panel.orderOut(nil)
        showSystemCursor()
    }

    private func positionPanel() {
        let mouse = NSEvent.mouseLocation
        let size = panel.frame.size
        let hotspot = settings.hotspot
        let origin = CGPoint(
            x: mouse.x - hotspot.x,
            y: mouse.y - (size.height - hotspot.y)
        )

        panel.setFrameOrigin(origin)
    }

    @objc private func timerFired() {
        positionPanel()
    }

    private func hideSystemCursor() {
        guard !isCursorHidden else { return }
        CGDisplayHideCursor(CGMainDisplayID())
        isCursorHidden = true
    }

    private func showSystemCursor() {
        guard isCursorHidden else { return }
        CGDisplayShowCursor(CGMainDisplayID())
        isCursorHidden = false
    }
}
