import AppKit
import CoreGraphics

@MainActor
final class CursorOverlayController {
    private let panel: NSPanel
    private let imageView: NSImageView
    private var timer: Timer?
    private var globalClickMonitor: Any?
    private var localClickMonitor: Any?
    private var settings = CursorSettings()
    private var isCursorHidden = false
    private var wasMouseButtonDown = false
    private var lastRegisteredClickTime: TimeInterval = 0
    var onPointerClick: (() -> Void)?

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
        guard settings.canRenderPointer else {
            imageView.image = nil
            return
        }

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
        guard settings.canRenderPointer else { return }
        hideSystemCursor()
        panel.orderFrontRegardless()
        positionPanel()
        wasMouseButtonDown = isMouseButtonDown()
        lastRegisteredClickTime = 0
        installClickMonitors()

        timer = Timer.scheduledTimer(
            timeInterval: 1.0 / 240.0,
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
        removeClickMonitors()
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

        let isButtonDown = isMouseButtonDown()
        if isButtonDown && !wasMouseButtonDown {
            registerPointerClick()
        }
        wasMouseButtonDown = isButtonDown
    }

    private func isMouseButtonDown() -> Bool {
        NSEvent.pressedMouseButtons != 0 ||
            CGEventSource.buttonState(.hidSystemState, button: .left) ||
            CGEventSource.buttonState(.hidSystemState, button: .right) ||
            CGEventSource.buttonState(.hidSystemState, button: .center)
    }

    private func installClickMonitors() {
        removeClickMonitors()

        let mask: NSEvent.EventTypeMask = [.leftMouseDown, .rightMouseDown, .otherMouseDown]
        globalClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: mask) { [weak self] _ in
            Task { @MainActor in
                self?.registerPointerClick()
            }
        }

        localClickMonitor = NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
            self?.registerPointerClick()
            return event
        }
    }

    private func removeClickMonitors() {
        if let globalClickMonitor {
            NSEvent.removeMonitor(globalClickMonitor)
            self.globalClickMonitor = nil
        }

        if let localClickMonitor {
            NSEvent.removeMonitor(localClickMonitor)
            self.localClickMonitor = nil
        }
    }

    private func registerPointerClick() {
        let now = ProcessInfo.processInfo.systemUptime
        guard now - lastRegisteredClickTime > 0.04 else { return }
        lastRegisteredClickTime = now
        onPointerClick?()
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
