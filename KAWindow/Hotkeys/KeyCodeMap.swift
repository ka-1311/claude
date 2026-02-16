import CoreGraphics

struct KeyCodeMap {
    static let map: [UInt16: String] = [
        0x00: "A", 0x01: "S", 0x02: "D", 0x03: "F", 0x04: "H",
        0x05: "G", 0x06: "Z", 0x07: "X", 0x08: "C", 0x09: "V",
        0x0B: "B", 0x0C: "Q", 0x0D: "W", 0x0E: "E", 0x0F: "R",
        0x10: "Y", 0x11: "T", 0x12: "1", 0x13: "2", 0x14: "3",
        0x15: "4", 0x16: "6", 0x17: "5", 0x18: "=", 0x19: "9",
        0x1A: "7", 0x1B: "-", 0x1C: "8", 0x1D: "0", 0x1E: "]",
        0x1F: "O", 0x20: "U", 0x21: "[", 0x22: "I", 0x23: "P",
        0x24: "Return", 0x25: "L", 0x26: "J", 0x27: "'", 0x28: "K",
        0x29: ";", 0x2A: "\\", 0x2B: ",", 0x2C: "/", 0x2D: "N",
        0x2E: "M", 0x2F: ".", 0x30: "Tab", 0x31: "Space",
        0x32: "`", 0x33: "Delete", 0x35: "Escape",
        0x37: "Command", 0x38: "Shift", 0x39: "Caps Lock",
        0x3A: "Option", 0x3B: "Control",
        0x60: "F5", 0x61: "F6", 0x62: "F7", 0x63: "F3",
        0x64: "F8", 0x65: "F9", 0x67: "F11", 0x69: "F13",
        0x6B: "F14", 0x6D: "F10", 0x6F: "F12", 0x71: "F15",
        0x72: "Help", 0x73: "Home", 0x74: "Page Up",
        0x75: "Forward Delete", 0x76: "F4", 0x77: "End",
        0x78: "F2", 0x79: "Page Down", 0x7A: "F1",
        0x7B: "\u{2190}", // Left Arrow
        0x7C: "\u{2192}", // Right Arrow
        0x7D: "\u{2193}", // Down Arrow
        0x7E: "\u{2191}", // Up Arrow
    ]

    /// Generate a human-readable display string for a key combination
    static func displayString(keyCode: UInt16, modifiers: CGEventFlags) -> String {
        var symbols: [String] = []
        if modifiers.contains(.maskControl) { symbols.append("\u{2303}") }    // ⌃
        if modifiers.contains(.maskAlternate) { symbols.append("\u{2325}") }  // ⌥
        if modifiers.contains(.maskShift) { symbols.append("\u{21E7}") }      // ⇧
        if modifiers.contains(.maskCommand) { symbols.append("\u{2318}") }    // ⌘

        let keyName = map[keyCode] ?? "Key\(keyCode)"
        symbols.append(keyName)
        return symbols.joined()
    }

    /// Generate a display string from raw modifier value
    static func displayString(keyCode: UInt16, modifiersRaw: UInt64) -> String {
        displayString(keyCode: keyCode, modifiers: CGEventFlags(rawValue: modifiersRaw))
    }
}
