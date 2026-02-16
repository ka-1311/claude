import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var permissionCheckTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("[KA Pointer] App launched")

        let granted = checkAccessibility()
        NSLog("[KA Pointer] Accessibility permission: %@", granted ? "granted" : "not granted")

        if granted {
            startMonitoring()
        } else {
            requestAccessibility()
        }

        // Poll for permission changes
        permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            if AXIsProcessTrusted() && !ModifierKeyMonitor.shared.isRunning {
                NSLog("[KA Pointer] Permission newly granted, starting monitors")
                self?.startMonitoring()
            }
        }

        // Re-enable after system wake
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { _ in
            if AXIsProcessTrusted() {
                NSLog("[KA Pointer] System wake, re-enabling monitors")
                ModifierKeyMonitor.shared.reEnable()
            }
        }
    }

    private func startMonitoring() {
        ModifierKeyMonitor.shared.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        permissionCheckTimer?.invalidate()
        ModifierKeyMonitor.shared.stop()
        OverlayWindowController.shared.hideOverlay()
    }

    // MARK: - Accessibility

    private func checkAccessibility() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    private func requestAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }
}
