import AppKit
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    private var cancellables = Set<AnyCancellable>()
    private var permissionCheckTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("[KA Window] App launched")

        // Load settings
        SettingsManager.shared.load()
        NSLog("[KA Window] Settings loaded, bindings count: %d", SettingsManager.shared.bindings.count)

        // Check accessibility permission
        let granted = AccessibilityPermission.shared.check()
        NSLog("[KA Window] Accessibility permission: %@", granted ? "granted" : "not granted")

        if granted {
            startHotkeys()
        } else {
            AccessibilityPermission.shared.requestAccess()
        }

        // Poll for permission changes
        permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            let nowGranted = AXIsProcessTrusted()
            if nowGranted && HotkeyManager.shared.eventTap == nil {
                NSLog("[KA Window] Permission newly granted, starting hotkeys")
                AccessibilityPermission.shared.isGranted = true
                self?.startHotkeys()
            }
        }

        // Re-enable event tap after system wake
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { _ in
            if AXIsProcessTrusted() {
                NSLog("[KA Window] System wake, re-enabling event tap")
                HotkeyManager.shared.reEnable()
            }
        }
    }

    private func startHotkeys() {
        HotkeyManager.shared.bindings = SettingsManager.shared.bindings
        NSLog("[KA Window] Starting hotkey manager with %d bindings", HotkeyManager.shared.bindings.count)
        for binding in HotkeyManager.shared.bindings {
            NSLog("[KA Window]   Binding: %@ -> keyCode=%d modifiers=%llu",
                  binding.action.displayName, binding.keyCode, binding.modifiers)
        }
        HotkeyManager.shared.start()
        NSLog("[KA Window] Event tap active: %@", HotkeyManager.shared.eventTap != nil ? "yes" : "no")
    }

    func applicationWillTerminate(_ notification: Notification) {
        permissionCheckTimer?.invalidate()
        HotkeyManager.shared.stop()
    }
}
