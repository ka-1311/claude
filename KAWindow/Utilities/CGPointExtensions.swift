import CoreGraphics
import AppKit

extension CGRect {
    /// Convert from NSScreen coordinates (bottom-left origin) to
    /// AX coordinates (top-left origin).
    func toAXCoordinates() -> CGRect {
        let primaryScreenHeight = NSScreen.screens.first?.frame.height ?? 0
        return CGRect(
            x: origin.x,
            y: primaryScreenHeight - origin.y - height,
            width: width,
            height: height
        )
    }

    /// Convert from AX coordinates (top-left origin) to
    /// NSScreen coordinates (bottom-left origin).
    func toNSScreenCoordinates() -> CGRect {
        let primaryScreenHeight = NSScreen.screens.first?.frame.height ?? 0
        return CGRect(
            x: origin.x,
            y: primaryScreenHeight - origin.y - height,
            width: width,
            height: height
        )
    }
}
