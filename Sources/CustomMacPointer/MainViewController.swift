import AppKit
import UniformTypeIdentifiers

final class MainViewController: NSViewController {
    private let state: AppState
    private let overlayController: CursorOverlayController

    private let previewView = CursorPreviewView()
    private let importButton = NSButton(title: "Import PNG", target: nil, action: nil)
    private let startButton = NSButton(title: "Start Pointer", target: nil, action: nil)
    private let stopButton = NSButton(title: "Stop Pointer", target: nil, action: nil)
    private let sizeSlider = NSSlider(value: 48, minValue: 16, maxValue: 160, target: nil, action: nil)
    private let sizeValueLabel = NSTextField(labelWithString: "48 px")
    private let fileLabel = NSTextField(labelWithString: "No PNG imported")
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
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        wireActions()
        refreshUI()

        state.onChange = { [weak self] settings in
            self?.previewView.settings = settings
            self?.overlayController.update(settings: settings)
            self?.refreshControls(for: settings)
        }
    }

    private func buildLayout() {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 14
        stack.edgeInsets = NSEdgeInsets(top: 22, left: 22, bottom: 22, right: 22)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let title = NSTextField(labelWithString: "Custom Mac Pointer")
        title.font = .systemFont(ofSize: 20, weight: .semibold)

        previewView.translatesAutoresizingMaskIntoConstraints = false

        fileLabel.font = .systemFont(ofSize: 12)
        fileLabel.textColor = .secondaryLabelColor
        fileLabel.lineBreakMode = .byTruncatingMiddle
        fileLabel.maximumNumberOfLines = 1

        statusLabel.font = .systemFont(ofSize: 12)
        statusLabel.textColor = .secondaryLabelColor

        let sizeRow = NSStackView(views: [label("Size"), sizeSlider, sizeValueLabel])
        sizeRow.orientation = .horizontal
        sizeRow.alignment = .centerY
        sizeRow.spacing = 10

        let buttonRow = NSStackView(views: [startButton, stopButton])
        buttonRow.orientation = .horizontal
        buttonRow.spacing = 8

        stack.addArrangedSubview(title)
        stack.addArrangedSubview(importButton)
        stack.addArrangedSubview(fileLabel)
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
            importButton.widthAnchor.constraint(equalToConstant: 120),
            sizeSlider.widthAnchor.constraint(equalToConstant: 250),
            startButton.widthAnchor.constraint(equalToConstant: 118),
            stopButton.widthAnchor.constraint(equalToConstant: 118)
        ])
    }

    private func wireActions() {
        importButton.target = self
        importButton.action = #selector(importImage)

        sizeSlider.target = self
        sizeSlider.action = #selector(sizeChanged)

        startButton.target = self
        startButton.action = #selector(startPointer)

        stopButton.target = self
        stopButton.action = #selector(stopPointer)
    }

    private func refreshUI() {
        let settings = state.settings
        sizeSlider.doubleValue = settings.size
        previewView.settings = settings
        overlayController.update(settings: settings)
        refreshControls(for: settings)
    }

    private func refreshControls(for settings: CursorSettings) {
        sizeValueLabel.stringValue = "\(Int(settings.size.rounded())) px"
        startButton.isEnabled = settings.importedImage != nil && !overlayController.isRunning
        stopButton.isEnabled = overlayController.isRunning
    }

    private func label(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabelColor
        return label
    }

    @objc private func importImage() {
        let panel = NSOpenPanel()
        panel.title = "Choose pointer PNG"
        panel.message = "Choose a PNG image to use as your pointer."
        panel.allowedContentTypes = [.png]
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.resolvesAliases = true

        runOpenPanel(panel) { [weak self] response in
            guard let self else { return }
            guard response == .OK else {
                fileLabel.stringValue = "No PNG imported"
                return
            }

            guard let url = panel.url else {
                presentAlert(title: "Import failed", message: "No PNG file was selected.")
                return
            }

            guard let image = NSImage(contentsOf: url), image.isValid, image.size.width > 0, image.size.height > 0 else {
                presentAlert(title: "Import failed", message: "macOS could not decode that PNG. Try another file.")
                return
            }

            var settings = state.settings
            settings.importedImage = image
            fileLabel.stringValue = url.lastPathComponent
            state.settings = settings
        }
    }

    @objc private func sizeChanged() {
        var settings = state.settings
        settings.size = CGFloat(sizeSlider.doubleValue.rounded())
        state.settings = settings
    }

    @objc private func startPointer() {
        guard state.settings.importedImage != nil else {
            presentAlert(title: "Import a PNG first", message: "Choose a PNG image before starting the pointer overlay.")
            return
        }

        overlayController.start()
        refreshControls(for: state.settings)
        statusLabel.stringValue = "Pointer overlay is running"
    }

    @objc private func stopPointer() {
        overlayController.stop()
        refreshControls(for: state.settings)
        statusLabel.stringValue = "Pointer overlay is off"
    }

    private func runOpenPanel(_ panel: NSOpenPanel, completion: @escaping (NSApplication.ModalResponse) -> Void) {
        if let window = view.window {
            panel.beginSheetModal(for: window, completionHandler: completion)
        } else {
            completion(panel.runModal())
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
