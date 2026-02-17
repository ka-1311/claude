import AppKit
import ApplicationServices

class AccessibilityElement {
    let element: AXUIElement

    init(_ element: AXUIElement) {
        self.element = element
    }

    /// Get the focused window of the frontmost application
    static func focusedWindow() -> AccessibilityElement? {
        guard let app = NSWorkspace.shared.frontmostApplication else { return nil }
        let appElement = AXUIElementCreateApplication(app.processIdentifier)

        var windowRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &windowRef)
        guard result == .success, let window = windowRef else { return nil }

        return AccessibilityElement(window as! AXUIElement)
    }

    // MARK: - Position

    var position: CGPoint? {
        get {
            var ref: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(element, kAXPositionAttribute as CFString, &ref)
            guard result == .success, let value = ref else { return nil }

            var point = CGPoint.zero
            if AXValueGetValue(value as! AXValue, .cgPoint, &point) {
                return point
            }
            return nil
        }
        set {
            guard var point = newValue else { return }
            guard let value = AXValueCreate(.cgPoint, &point) else { return }
            AXUIElementSetAttributeValue(element, kAXPositionAttribute as CFString, value)
        }
    }

    // MARK: - Size

    var size: CGSize? {
        get {
            var ref: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(element, kAXSizeAttribute as CFString, &ref)
            guard result == .success, let value = ref else { return nil }

            var size = CGSize.zero
            if AXValueGetValue(value as! AXValue, .cgSize, &size) {
                return size
            }
            return nil
        }
        set {
            guard var size = newValue else { return }
            guard let value = AXValueCreate(.cgSize, &size) else { return }
            AXUIElementSetAttributeValue(element, kAXSizeAttribute as CFString, value)
        }
    }

    // MARK: - Frame

    var frame: CGRect? {
        guard let pos = position, let sz = size else { return nil }
        return CGRect(origin: pos, size: sz)
    }

    /// Set window frame using the three-step pattern for reliable cross-display moves.
    /// 1. Resize to target size (constrained to current display)
    /// 2. Move to target position (window moves to new display)
    /// 3. Resize again (now properly constrained to new display)
    func setFrame(_ rect: CGRect) {
        // Step 1: Pre-resize
        self.size = rect.size
        waitForSize(rect.size)

        // Step 2: Move
        self.position = rect.origin
        waitForPosition(rect.origin)

        // Step 3: Final resize
        self.size = rect.size
        waitForSize(rect.size)
    }

    private func waitForSize(_ expected: CGSize, timeout: UInt32 = 200_000, interval: UInt32 = 10_000) {
        var elapsed: UInt32 = 0
        while elapsed < timeout {
            if let current = self.size,
               abs(current.width - expected.width) < 2,
               abs(current.height - expected.height) < 2 { return }
            usleep(interval)
            elapsed += interval
        }
    }

    private func waitForPosition(_ expected: CGPoint, timeout: UInt32 = 200_000, interval: UInt32 = 10_000) {
        var elapsed: UInt32 = 0
        while elapsed < timeout {
            if let current = self.position,
               abs(current.x - expected.x) < 2,
               abs(current.y - expected.y) < 2 { return }
            usleep(interval)
            elapsed += interval
        }
    }

    /// Check if the window is resizable
    var isResizable: Bool {
        var isSettable: DarwinBoolean = false
        let result = AXUIElementIsAttributeSettable(element, kAXSizeAttribute as CFString, &isSettable)
        return result == .success && isSettable.boolValue
    }

    /// Check if the window is movable
    var isMovable: Bool {
        var isSettable: DarwinBoolean = false
        let result = AXUIElementIsAttributeSettable(element, kAXPositionAttribute as CFString, &isSettable)
        return result == .success && isSettable.boolValue
    }
}
