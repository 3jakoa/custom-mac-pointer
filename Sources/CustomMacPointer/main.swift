import AppKit

@MainActor
private final class ApplicationRuntime {
    static let shared = ApplicationRuntime()

    let delegate = AppDelegate()
}

@MainActor
private func runApplication() {
    let application = NSApplication.shared
    application.delegate = ApplicationRuntime.shared.delegate
    application.setActivationPolicy(.regular)
    application.run()
}

runApplication()
