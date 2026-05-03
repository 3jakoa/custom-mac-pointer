import AppKit

final class MainViewController: NSViewController {
    private let state: AppState
    private let overlayController: CursorOverlayController

    private let previewView = CursorPreviewView()
    private let startButton = NSButton(title: "Start Burek", target: nil, action: nil)
    private let stopButton = NSButton(title: "Stop Pointer", target: nil, action: nil)
    private let sizeSlider = NSSlider(value: 72, minValue: 32, maxValue: 180, target: nil, action: nil)
    private let sizeValueLabel = NSTextField(labelWithString: "72 px")
    private let libraryLabel = NSTextField(labelWithString: "No Bureks bundled")
    private let statusLabel = NSTextField(labelWithString: "Pointer overlay is off")

    init(state: AppState, overlayController: CursorOverlayController) {
        self.state = state
        self.overlayController = overlayController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView()
        view.appearance = NSAppearance(named: .aqua)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(red: 0.98, green: 0.86, blue: 0.58, alpha: 1).cgColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        wireActions()
        refreshUI()

        overlayController.onPointerClick = { [weak self] in
            guard let self else { return }
            self.state.advanceBorek()
            self.statusLabel.stringValue = self.runningStatusText()
        }

        state.onChange = { [weak self] settings in
            self?.previewView.settings = settings
            self?.overlayController.update(settings: settings)
            self?.refreshControls(for: settings)
        }
    }

    private func buildLayout() {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .centerX
        stack.spacing = 16
        stack.edgeInsets = NSEdgeInsets(top: 28, left: 24, bottom: 24, right: 24)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let title = NSTextField(labelWithString: "Burek Mac Pointer")
        title.font = .systemFont(ofSize: 28, weight: .heavy)
        title.textColor = NSColor(red: 0.32, green: 0.16, blue: 0.07, alpha: 1)
        title.alignment = .center

        let subtitle = NSTextField(labelWithString: "freshly baked cursor chaos")
        subtitle.font = .systemFont(ofSize: 13, weight: .semibold)
        subtitle.textColor = NSColor(red: 0.05, green: 0.31, blue: 0.22, alpha: 1)
        subtitle.alignment = .center

        previewView.translatesAutoresizingMaskIntoConstraints = false

        libraryLabel.font = .systemFont(ofSize: 12)
        libraryLabel.textColor = NSColor(red: 0.45, green: 0.25, blue: 0.12, alpha: 1)
        libraryLabel.alignment = .center
        libraryLabel.lineBreakMode = .byTruncatingMiddle
        libraryLabel.maximumNumberOfLines = 1

        statusLabel.font = .systemFont(ofSize: 12)
        statusLabel.textColor = NSColor(red: 0.36, green: 0.19, blue: 0.09, alpha: 1)
        statusLabel.alignment = .center

        sizeValueLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .semibold)
        sizeValueLabel.textColor = NSColor(red: 0.36, green: 0.19, blue: 0.09, alpha: 1)
        sizeValueLabel.alignment = .right

        let sizeTitle = NSTextField(labelWithString: "Burek size")
        sizeTitle.font = .systemFont(ofSize: 12, weight: .semibold)
        sizeTitle.textColor = NSColor(red: 0.45, green: 0.25, blue: 0.12, alpha: 1)

        let sizeRow = NSStackView(views: [sizeTitle, sizeSlider, sizeValueLabel])
        sizeRow.orientation = .horizontal
        sizeRow.alignment = .centerY
        sizeRow.spacing = 10

        let buttonRow = NSStackView(views: [startButton, stopButton])
        buttonRow.orientation = .horizontal
        buttonRow.alignment = .centerY
        buttonRow.spacing = 12

        configureButton(startButton, color: NSColor(red: 0.13, green: 0.45, blue: 0.32, alpha: 1))
        configureButton(stopButton, color: NSColor(red: 0.72, green: 0.24, blue: 0.11, alpha: 1))

        stack.addArrangedSubview(title)
        stack.addArrangedSubview(subtitle)
        stack.addArrangedSubview(libraryLabel)
        stack.addArrangedSubview(previewView)
        stack.addArrangedSubview(sizeRow)
        stack.addArrangedSubview(buttonRow)
        stack.addArrangedSubview(statusLabel)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.topAnchor),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            previewView.widthAnchor.constraint(equalTo: stack.widthAnchor, constant: -44),
            previewView.heightAnchor.constraint(equalToConstant: 220),
            sizeRow.widthAnchor.constraint(equalTo: stack.widthAnchor, constant: -44),
            sizeSlider.widthAnchor.constraint(equalToConstant: 210),
            sizeValueLabel.widthAnchor.constraint(equalToConstant: 54),
            startButton.widthAnchor.constraint(equalToConstant: 140),
            stopButton.widthAnchor.constraint(equalToConstant: 140),
            startButton.heightAnchor.constraint(equalToConstant: 36),
            stopButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    private func wireActions() {
        sizeSlider.target = self
        sizeSlider.action = #selector(sizeChanged)

        startButton.target = self
        startButton.action = #selector(startPointer)

        stopButton.target = self
        stopButton.action = #selector(stopPointer)
    }

    private func refreshUI() {
        let settings = state.settings
        sizeSlider.doubleValue = Double(settings.size)
        previewView.settings = settings
        overlayController.update(settings: settings)
        refreshControls(for: settings)
    }

    private func refreshControls(for settings: CursorSettings) {
        libraryLabel.stringValue = libraryText(for: settings)
        sizeValueLabel.stringValue = "\(Int(settings.size.rounded())) px"
        startButton.isEnabled = settings.canRenderPointer && !overlayController.isRunning
        stopButton.isEnabled = overlayController.isRunning
    }

    private func configureButton(_ button: NSButton, color: NSColor) {
        button.bezelStyle = .rounded
        button.font = .systemFont(ofSize: 14, weight: .semibold)
        button.contentTintColor = color
    }

    @objc private func sizeChanged() {
        var settings = state.settings
        settings.size = CGFloat(sizeSlider.doubleValue.rounded())
        state.settings = settings
    }

    @objc private func startPointer() {
        guard state.settings.canRenderPointer else {
            presentAlert(
                title: "No pointer artwork",
                message: "Add Burek images to the bundled Bureks folder before starting the pointer overlay."
            )
            return
        }

        overlayController.start()
        refreshControls(for: state.settings)
        statusLabel.stringValue = runningStatusText()
    }

    @objc private func stopPointer() {
        overlayController.stop()
        refreshControls(for: state.settings)
        statusLabel.stringValue = "Pointer overlay is off"
    }

    private func libraryText(for settings: CursorSettings) -> String {
        guard !settings.boreks.isEmpty else {
            return "No Bureks bundled yet"
        }

        let activeName = settings.activeBorek?.name ?? "Burek"
        return "\(settings.boreks.count) Bureks loaded - \(activeName)"
    }

    private func runningStatusText() -> String {
        "Burek pointer is running"
    }

    private func presentAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning

        if let window = view.window {
            alert.beginSheetModal(for: window)
        } else {
            alert.runModal()
        }
    }
}
