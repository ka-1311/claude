import AppKit
import SwiftUI

class SettingsWindowController {
    static let shared = SettingsWindowController()

    private var window: NSWindow?

    private init() {}

    func showSettings() {
        if let existing = window, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = PreferencesView()
        let hostingController = NSHostingController(rootView: settingsView)

        let newWindow = NSWindow(contentViewController: hostingController)
        newWindow.title = "KA Window Preferences"
        newWindow.styleMask = [.titled, .closable]
        newWindow.setContentSize(NSSize(width: 520, height: 420))
        newWindow.center()
        newWindow.isReleasedWhenClosed = false
        self.window = newWindow

        // Temporarily become a regular app so the window comes to front
        NSApp.setActivationPolicy(.regular)
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        // Observe window close to revert to accessory policy (hide from Dock)
        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: newWindow,
            queue: .main
        ) { [weak self] _ in
            NSApp.setActivationPolicy(.accessory)
            self?.window = nil
        }
    }
}
