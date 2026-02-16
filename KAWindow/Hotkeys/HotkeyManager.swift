import CoreGraphics
import AppKit

class HotkeyManager {
    static let shared = HotkeyManager()

    var bindings: [HotkeyBinding] = []
    private(set) var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    private init() {}

    func start() {
        guard eventTap == nil else { return }

        let eventMask: CGEventMask = (1 << CGEventType.keyDown.rawValue)
        let userInfo = Unmanaged.passUnretained(self).toOpaque()

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: hotkeyEventCallback,
            userInfo: userInfo
        ) else {
            NSLog("[KA Window] Failed to create CGEvent tap. Accessibility permission may not be granted.")
            return
        }

        self.eventTap = tap
        self.runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        NSLog("[KA Window] Event tap started successfully.")
    }

    func stop() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            if let source = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
            }
        }
        eventTap = nil
        runLoopSource = nil
    }

    /// Re-enable the event tap (e.g., after system wake)
    func reEnable() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
        } else {
            start()
        }
    }

    /// Handle a CGEvent, returning nil to swallow matched events
    func handleEvent(_ event: CGEvent) -> CGEvent? {
        let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))

        for binding in bindings {
            if binding.matches(event: event) {
                NSLog("[KA Window] Matched! keyCode=%d action=%@", keyCode, binding.action.displayName)
                DispatchQueue.main.async {
                    WindowManager.shared.execute(binding.action)
                }
                return nil // Swallow the event
            }
        }
        return event // Pass through unmatched events
    }
}

// Global C-compatible callback function
private func hotkeyEventCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    // Handle tap being disabled by the system
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let tap = HotkeyManager.shared.eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
        }
        return Unmanaged.passUnretained(event)
    }

    if type == .keyDown {
        let kc = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
        let fl = event.flags
        var mods: [String] = []
        if fl.contains(.maskCommand) { mods.append("Cmd") }
        if fl.contains(.maskShift) { mods.append("Shift") }
        if fl.contains(.maskControl) { mods.append("Ctrl") }
        if fl.contains(.maskAlternate) { mods.append("Opt") }
        let modStr = mods.isEmpty ? "none" : mods.joined(separator: "+")
        let keyName = KeyCodeMap.map[kc] ?? "key\(kc)"
        NSLog("[KA Window] CB keyDown: %@+%@ (keyCode=%d flags=0x%llx)", modStr, keyName, kc, fl.rawValue)
    }

    guard type == .keyDown, let userInfo = userInfo else {
        return Unmanaged.passUnretained(event)
    }

    let manager = Unmanaged<HotkeyManager>.fromOpaque(userInfo).takeUnretainedValue()
    if let result = manager.handleEvent(event) {
        return Unmanaged.passUnretained(result)
    }
    return nil // Event was swallowed
}
