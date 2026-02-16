import AppKit
import Combine

class AccessibilityPermission: ObservableObject {
    static let shared = AccessibilityPermission()

    @Published var isGranted: Bool = false
    private var pollingTimer: Timer?

    private init() {
        isGranted = check()
    }

    /// Check accessibility permission without prompting
    func check() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    /// Trigger the system accessibility permission dialog
    func requestAccess() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    /// Start polling for permission changes (user may toggle in System Settings)
    func startPolling() {
        pollingTimer?.invalidate()
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let granted = AXIsProcessTrusted()
            if granted != self.isGranted {
                DispatchQueue.main.async {
                    self.isGranted = granted
                }
            }
        }
    }

    /// Stop polling
    func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
}
