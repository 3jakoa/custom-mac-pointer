import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow?
    private var statusItem: NSStatusItem?
    private let overlayController = CursorOverlayController()
    private let state = AppState(boreks: BurekLibrary.loadBundledBureks())
    private let licenseController = AppLicenseController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        buildMenu()
        buildStatusItem()
        showSettingsWindow(activate: true)
        Task {
            await licenseController.validateStoredLicense()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showSettingsWindow(activate: true)
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        overlayController.stop()
    }

    private func makeSettingsWindow() -> NSWindow {
        let viewController = MainViewController(
            state: state,
            overlayController: overlayController,
            licenseController: licenseController
        )
        let window = NSWindow(contentViewController: viewController)
        window.title = "Burek Cursor"
        window.appearance = NSAppearance(named: .aqua)
        window.setContentSize(NSSize(width: 380, height: 666))
        window.minSize = NSSize(width: 380, height: 666)
        window.maxSize = NSSize(width: 380, height: 666)
        window.backgroundColor = Design.cream
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.styleMask.insert(.fullSizeContentView)
        window.styleMask.remove(.resizable)
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        window.center()

        return window
    }

    private func showSettingsWindow(activate: Bool) {
        if window == nil {
            window = makeSettingsWindow()
        }

        guard let window else { return }
        if !window.isVisible {
            window.center()
        }
        window.makeKeyAndOrderFront(nil)

        if activate {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func buildMenu() {
        let mainMenu = NSMenu()

        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(
            withTitle: "Show Burek Controls",
            action: #selector(showSettingsWindowFromMenu(_:)),
            keyEquivalent: "0"
        )
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(
            withTitle: "Quit Burek Cursor",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        let editMenuItem = NSMenuItem()
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        editMenu.addItem(withTitle: "Redo", action: Selector(("redo:")), keyEquivalent: "Z")
        editMenu.addItem(NSMenuItem.separator())
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)

        NSApp.mainMenu = mainMenu
    }

    private func buildStatusItem() {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "Burek"
        statusItem.button?.toolTip = "Burek Cursor"

        let menu = NSMenu()
        menu.addItem(
            withTitle: "Show Burek Controls",
            action: #selector(showSettingsWindowFromMenu(_:)),
            keyEquivalent: ""
        )
        menu.addItem(NSMenuItem.separator())
        menu.addItem(
            withTitle: "Quit Burek Cursor",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        statusItem.menu = menu

        self.statusItem = statusItem
    }

    @objc private func showSettingsWindowFromMenu(_ sender: Any?) {
        showSettingsWindow(activate: true)
    }
}
