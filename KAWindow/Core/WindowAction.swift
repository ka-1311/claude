import CoreGraphics

enum WindowAction: String, CaseIterable, Codable, Identifiable {
    case leftHalf
    case rightHalf
    case topRightQuarter
    case bottomRightQuarter
    case maximize
    case leftTwoThirds
    case rightOneThird
    case moveToNextDisplay
    case moveToPreviousDisplay

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .leftHalf:             return "Left Half"
        case .rightHalf:            return "Right Half"
        case .topRightQuarter:      return "Top Right Quarter"
        case .bottomRightQuarter:   return "Bottom Right Quarter"
        case .maximize:             return "Maximize"
        case .leftTwoThirds:        return "Left Two Thirds"
        case .rightOneThird:        return "Right One Third"
        case .moveToNextDisplay:    return "Next Display"
        case .moveToPreviousDisplay: return "Previous Display"
        }
    }

    var defaultKeyCode: UInt16 {
        switch self {
        case .leftHalf:             return 0x7B // Left Arrow
        case .rightHalf:            return 0x7C // Right Arrow
        case .topRightQuarter:      return 0x7E // Up Arrow
        case .bottomRightQuarter:   return 0x7D // Down Arrow
        case .maximize:             return 0x24 // Return
        case .leftTwoThirds:        return 0x7B // Left Arrow
        case .rightOneThird:        return 0x7C // Right Arrow
        case .moveToNextDisplay:    return 0x7D // Down Arrow
        case .moveToPreviousDisplay: return 0x7E // Up Arrow
        }
    }

    var defaultModifiers: CGEventFlags {
        switch self {
        case .leftHalf, .rightHalf, .topRightQuarter, .bottomRightQuarter:
            return [.maskCommand, .maskControl]
        case .maximize, .leftTwoThirds, .rightOneThird, .moveToNextDisplay, .moveToPreviousDisplay:
            return [.maskCommand, .maskShift, .maskControl]
        }
    }

    var defaultBinding: HotkeyBinding {
        HotkeyBinding(keyCode: defaultKeyCode, modifiers: defaultModifiers, action: self)
    }

    /// Calculate the target frame for this action on the given screen frame (in AX coordinates).
    func targetRect(for screenFrame: CGRect) -> CGRect {
        let x = screenFrame.origin.x
        let y = screenFrame.origin.y
        let w = screenFrame.width
        let h = screenFrame.height

        switch self {
        case .leftHalf:
            return CGRect(x: x, y: y, width: w / 2, height: h)
        case .rightHalf:
            return CGRect(x: x + w / 2, y: y, width: w / 2, height: h)
        case .topRightQuarter:
            return CGRect(x: x + w / 2, y: y, width: w / 2, height: h / 2)
        case .bottomRightQuarter:
            return CGRect(x: x + w / 2, y: y + h / 2, width: w / 2, height: h / 2)
        case .maximize:
            return screenFrame
        case .leftTwoThirds:
            return CGRect(x: x, y: y, width: w * 2 / 3, height: h)
        case .rightOneThird:
            return CGRect(x: x + w * 2 / 3, y: y, width: w / 3, height: h)
        case .moveToNextDisplay, .moveToPreviousDisplay:
            // These are handled by WindowManager directly
            return screenFrame
        }
    }
}
