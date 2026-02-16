import SwiftUI
import AppKit
import CoreGraphics

struct ShortcutRecorderView: NSViewRepresentable {
    let keyCode: UInt16
    let modifiers: CGEventFlags
    let onRecord: (UInt16, CGEventFlags) -> Void

    func makeNSView(context: Context) -> ShortcutRecorderNSView {
        let view = ShortcutRecorderNSView()
        view.keyCode = keyCode
        view.modifiers = modifiers
        view.onRecord = onRecord
        return view
    }

    func updateNSView(_ nsView: ShortcutRecorderNSView, context: Context) {
        nsView.keyCode = keyCode
        nsView.modifiers = modifiers
        nsView.updateDisplay()
    }
}

class ShortcutRecorderNSView: NSView {
    var keyCode: UInt16 = 0
    var modifiers: CGEventFlags = []
    var onRecord: ((UInt16, CGEventFlags) -> Void)?

    private var isRecording = false
    private var localMonitor: Any?
    private let label = NSTextField(labelWithString: "")

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        wantsLayer = true
        layer?.cornerRadius = 6
        layer?.borderWidth = 1
        layer?.borderColor = NSColor.separatorColor.cgColor

        label.alignment = .center
        label.font = .systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -4),
        ])

        let click = NSClickGestureRecognizer(target: self, action: #selector(handleClick))
        addGestureRecognizer(click)

        updateDisplay()
    }

    func updateDisplay() {
        if isRecording {
            label.stringValue = "Press shortcut..."
            label.textColor = .systemBlue
            layer?.borderColor = NSColor.controlAccentColor.cgColor
            layer?.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.1).cgColor
        } else {
            label.stringValue = KeyCodeMap.displayString(keyCode: keyCode, modifiers: modifiers)
            label.textColor = .labelColor
            layer?.borderColor = NSColor.separatorColor.cgColor
            layer?.backgroundColor = nil
        }
    }

    @objc private func handleClick() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        isRecording = true
        updateDisplay()

        // Temporarily disable the global event tap to capture keys locally
        if let tap = HotkeyManager.shared.eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            guard let self = self else { return event }

            // Escape cancels recording
            if event.keyCode == 0x35 {
                self.stopRecording()
                return nil
            }

            // Only accept keys with at least one modifier (Cmd, Ctrl, Opt, Shift)
            let mods = event.modifierFlags.intersection([.command, .shift, .control, .option])
            guard !mods.isEmpty else { return nil }

            // Convert NSEvent modifier flags to CGEventFlags
            var cgFlags: CGEventFlags = []
            if mods.contains(.command) { cgFlags.insert(.maskCommand) }
            if mods.contains(.shift) { cgFlags.insert(.maskShift) }
            if mods.contains(.control) { cgFlags.insert(.maskControl) }
            if mods.contains(.option) { cgFlags.insert(.maskAlternate) }

            self.keyCode = event.keyCode
            self.modifiers = cgFlags
            self.onRecord?(event.keyCode, cgFlags)
            self.stopRecording()
            return nil
        }
    }

    private func stopRecording() {
        isRecording = false
        updateDisplay()

        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }

        // Re-enable the global event tap
        if let tap = HotkeyManager.shared.eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
        }
    }

    override var intrinsicContentSize: NSSize {
        NSSize(width: 160, height: 28)
    }
}
