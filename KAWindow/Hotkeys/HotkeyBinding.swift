import CoreGraphics

struct HotkeyBinding: Codable, Equatable {
    let keyCode: UInt16
    let modifiers: UInt64  // Stored as raw value of CGEventFlags
    let action: WindowAction

    init(keyCode: UInt16, modifiers: CGEventFlags, action: WindowAction) {
        self.keyCode = keyCode
        self.modifiers = modifiers.rawValue
        self.action = action
    }

    var eventFlags: CGEventFlags {
        CGEventFlags(rawValue: modifiers)
    }

    /// Relevant modifier mask: only check Cmd, Shift, Ctrl, Option
    private static let relevantModifiers: CGEventFlags = [.maskCommand, .maskShift, .maskControl, .maskAlternate]

    /// Check if a CGEvent matches this binding
    func matches(event: CGEvent) -> Bool {
        let eventKeyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
        let eventModifiers = event.flags.intersection(Self.relevantModifiers)
        let bindingModifiers = eventFlags.intersection(Self.relevantModifiers)
        return eventKeyCode == keyCode && eventModifiers == bindingModifiers
    }
}
