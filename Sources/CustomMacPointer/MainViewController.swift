import AppKit

final class MainViewController: NSViewController {
    private let state: AppState
    private let overlayController: CursorOverlayController

    private let previewView = CursorPreviewView()
    private let startButton = BurekButton(title: "Start Burek", style: .ghost)
    private let stopButton = BurekButton(title: "Stop Burek", style: .primary)
    private let sizeSlider = BurekSizeSlider()
    private let modeControl = BurekModeControl()
    private let sizeValueLabel = NSTextField(labelWithString: "106 px")
    private let libraryChip = StatusChipView()
    private let statusLine = StatusLineView()

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
        view.layer?.backgroundColor = Design.cream.cgColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        wireActions()
        refreshUI()

        overlayController.onPointerClick = { [weak self] in
            guard let self else { return }
            self.state.advanceBorek()
            self.statusLine.text = self.runningStatusText(for: self.state.settings)
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
        stack.alignment = .width
        stack.distribution = .fill
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        stack.addArrangedSubview(makeTitleBar())
        stack.addArrangedSubview(makeHeader())
        stack.addArrangedSubview(makeStatusBar())
        stack.addArrangedSubview(makePreviewSection())
        stack.addArrangedSubview(makeControlsSection())

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.topAnchor),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func makeTitleBar() -> NSView {
        let section = SectionView()
        section.borderBottom = true
        section.translatesAutoresizingMaskIntoConstraints = false

        let title = NSTextField(labelWithString: "Burek Cursor")
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .systemFont(ofSize: 13, weight: .semibold)
        title.textColor = NSColor(red: 74 / 255, green: 46 / 255, blue: 26 / 255, alpha: 0.75)
        title.alignment = .center

        section.addSubview(title)

        NSLayoutConstraint.activate([
            section.heightAnchor.constraint(equalToConstant: 42),
            title.centerXAnchor.constraint(equalTo: section.centerXAnchor),
            title.centerYAnchor.constraint(equalTo: section.centerYAnchor, constant: 1)
        ])

        return section
    }

    private func makeHeader() -> NSView {
        let section = AppHeaderView()
        section.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            section.heightAnchor.constraint(equalToConstant: 85)
        ])

        return section
    }

    private func makeStatusBar() -> NSView {
        let section = SectionView()
        section.borderBottom = true
        section.borderAlpha = 0.13
        section.translatesAutoresizingMaskIntoConstraints = false
        section.addSubview(libraryChip)

        NSLayoutConstraint.activate([
            section.heightAnchor.constraint(equalToConstant: 45),
            libraryChip.leadingAnchor.constraint(equalTo: section.leadingAnchor, constant: 24),
            libraryChip.trailingAnchor.constraint(lessThanOrEqualTo: section.trailingAnchor, constant: -24),
            libraryChip.centerYAnchor.constraint(equalTo: section.centerYAnchor)
        ])

        return section
    }

    private func makePreviewSection() -> NSView {
        let section = SectionView()
        section.translatesAutoresizingMaskIntoConstraints = false
        previewView.translatesAutoresizingMaskIntoConstraints = false
        section.addSubview(previewView)

        NSLayoutConstraint.activate([
            section.heightAnchor.constraint(equalToConstant: 208),
            previewView.leadingAnchor.constraint(equalTo: section.leadingAnchor, constant: 20),
            previewView.trailingAnchor.constraint(equalTo: section.trailingAnchor, constant: -20),
            previewView.topAnchor.constraint(equalTo: section.topAnchor, constant: 14),
            previewView.heightAnchor.constraint(equalToConstant: 180)
        ])

        return section
    }

    private func makeControlsSection() -> NSView {
        let section = SectionView()
        section.borderTop = true
        section.borderAlpha = 0.13
        section.translatesAutoresizingMaskIntoConstraints = false

        let controls = NSStackView()
        controls.translatesAutoresizingMaskIntoConstraints = false
        controls.orientation = .vertical
        controls.alignment = .width
        controls.spacing = 16

        controls.addArrangedSubview(makeSizeRow())
        controls.addArrangedSubview(makeModeRow())
        controls.addArrangedSubview(makeButtonRow())
        controls.addArrangedSubview(statusLine)
        section.addSubview(controls)

        NSLayoutConstraint.activate([
            section.heightAnchor.constraint(equalToConstant: 194),
            controls.leadingAnchor.constraint(equalTo: section.leadingAnchor, constant: 24),
            controls.trailingAnchor.constraint(equalTo: section.trailingAnchor, constant: -24),
            controls.topAnchor.constraint(equalTo: section.topAnchor, constant: 18)
        ])

        return section
    }

    private func makeSizeRow() -> NSView {
        let label = controlLabel("Burek size")
        sizeSlider.translatesAutoresizingMaskIntoConstraints = false

        sizeValueLabel.translatesAutoresizingMaskIntoConstraints = false
        sizeValueLabel.font = .monospacedDigitSystemFont(ofSize: 12.5, weight: .semibold)
        sizeValueLabel.textColor = Design.brown
        sizeValueLabel.alignment = .right

        let row = NSStackView(views: [label, sizeSlider, sizeValueLabel])
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 78),
            sizeValueLabel.widthAnchor.constraint(equalToConstant: 44),
            row.heightAnchor.constraint(equalToConstant: 24)
        ])

        return row
    }

    private func makeModeRow() -> NSView {
        let label = controlLabel("Mode")
        modeControl.translatesAutoresizingMaskIntoConstraints = false

        let row = NSStackView(views: [label, modeControl])
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 78),
            modeControl.heightAnchor.constraint(equalToConstant: 30),
            row.heightAnchor.constraint(equalToConstant: 30)
        ])

        return row
    }

    private func makeButtonRow() -> NSView {
        let row = NSStackView(views: [startButton, stopButton])
        row.orientation = .horizontal
        row.alignment = .centerY
        row.distribution = .fillEqually
        row.spacing = 10
        row.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            startButton.heightAnchor.constraint(equalToConstant: 38),
            stopButton.heightAnchor.constraint(equalToConstant: 38),
            row.heightAnchor.constraint(equalToConstant: 40)
        ])

        return row
    }

    private func controlLabel(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = Design.brownMid
        label.alignment = .left
        return label
    }

    private func wireActions() {
        sizeSlider.target = self
        sizeSlider.action = #selector(sizeChanged)

        modeControl.target = self
        modeControl.action = #selector(modeChanged)

        startButton.target = self
        startButton.action = #selector(startPointer)

        stopButton.target = self
        stopButton.action = #selector(stopPointer)
    }

    private func refreshUI() {
        let settings = state.settings
        sizeSlider.value = settings.size
        modeControl.mode = settings.mode
        previewView.settings = settings
        overlayController.update(settings: settings)
        refreshControls(for: settings)
    }

    private func refreshControls(for settings: CursorSettings) {
        libraryChip.text = libraryText(for: settings)
        sizeValueLabel.stringValue = "\(Int(settings.size.rounded())) px"
        sizeSlider.value = settings.size
        modeControl.mode = settings.mode
        startButton.isEnabled = settings.canRenderPointer && !overlayController.isRunning
        stopButton.isEnabled = overlayController.isRunning
        statusLine.text = overlayController.isRunning ? runningStatusText(for: settings) : "Burek is stopped"
    }

    @objc private func sizeChanged() {
        var settings = state.settings
        settings.size = sizeSlider.value
        state.settings = settings
    }

    @objc private func modeChanged() {
        var settings = state.settings
        settings.mode = modeControl.mode
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
    }

    @objc private func stopPointer() {
        overlayController.stop()
        refreshControls(for: state.settings)
    }

    private func libraryText(for settings: CursorSettings) -> String {
        guard !settings.boreks.isEmpty else {
            return "No Bureks bundled yet"
        }

        let activeName = settings.activeBorek?.name ?? "Burek"
        return "\(settings.boreks.count) Bureks loaded - \(activeName)"
    }

    private func runningStatusText(for settings: CursorSettings) -> String {
        switch settings.mode {
        case .floating:
            return "Burek is floating near your pointer"
        case .pointer:
            return "Burek is following your pointer"
        }
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
