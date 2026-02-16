import AppKit

struct ScreenManager {
    /// Returns all screens sorted by x-position (left to right)
    static func orderedScreens() -> [NSScreen] {
        NSScreen.screens.sorted { $0.frame.origin.x < $1.frame.origin.x }
    }

    /// Find which screen contains the given window frame (AX coordinates, top-left origin).
    /// Uses the screen with the largest overlap area.
    static func screen(for windowFrame: CGRect) -> NSScreen? {
        let screens = NSScreen.screens
        guard !screens.isEmpty else { return nil }

        // Convert window frame from AX (top-left) to NSScreen (bottom-left) for comparison
        let primaryHeight = screens[0].frame.height
        let nsWindowFrame = CGRect(
            x: windowFrame.origin.x,
            y: primaryHeight - windowFrame.origin.y - windowFrame.height,
            width: windowFrame.width,
            height: windowFrame.height
        )

        var bestScreen: NSScreen?
        var bestArea: CGFloat = 0

        for screen in screens {
            let intersection = screen.frame.intersection(nsWindowFrame)
            if !intersection.isNull {
                let area = intersection.width * intersection.height
                if area > bestArea {
                    bestArea = area
                    bestScreen = screen
                }
            }
        }

        // Fallback to the main screen if no overlap found
        return bestScreen ?? NSScreen.main
    }

    /// Get the next screen relative to the given screen (wraps around)
    static func nextScreen(from current: NSScreen) -> NSScreen? {
        let screens = orderedScreens()
        guard screens.count > 1 else { return nil }
        guard let index = screens.firstIndex(of: current) else { return screens.first }
        let nextIndex = (index + 1) % screens.count
        return screens[nextIndex]
    }

    /// Get the previous screen relative to the given screen (wraps around)
    static func previousScreen(from current: NSScreen) -> NSScreen? {
        let screens = orderedScreens()
        guard screens.count > 1 else { return nil }
        guard let index = screens.firstIndex(of: current) else { return screens.first }
        let prevIndex = (index - 1 + screens.count) % screens.count
        return screens[prevIndex]
    }

    /// Convert NSScreen's visibleFrame (bottom-left origin) to AX coordinates (top-left origin).
    /// The primary screen's height is the reference for the Y-axis flip.
    static func axVisibleFrame(for screen: NSScreen) -> CGRect {
        let primaryHeight = NSScreen.screens[0].frame.height
        let visibleFrame = screen.visibleFrame

        return CGRect(
            x: visibleFrame.origin.x,
            y: primaryHeight - visibleFrame.origin.y - visibleFrame.height,
            width: visibleFrame.width,
            height: visibleFrame.height
        )
    }
}
