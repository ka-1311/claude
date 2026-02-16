import AppKit

class WindowManager {
    static let shared = WindowManager()

    private init() {}

    func execute(_ action: WindowAction) {
        guard AccessibilityPermission.shared.isGranted else { return }
        guard let window = AccessibilityElement.focusedWindow() else { return }
        guard window.isMovable else { return }
        guard let windowFrame = window.frame else { return }

        switch action {
        case .moveToNextDisplay:
            moveToDisplay(window: window, currentFrame: windowFrame, next: true)
        case .moveToPreviousDisplay:
            moveToDisplay(window: window, currentFrame: windowFrame, next: false)
        default:
            resizeOnCurrentScreen(window: window, currentFrame: windowFrame, action: action)
        }
    }

    private func resizeOnCurrentScreen(window: AccessibilityElement, currentFrame: CGRect, action: WindowAction) {
        guard let screen = ScreenManager.screen(for: currentFrame) else { return }
        let screenFrame = ScreenManager.axVisibleFrame(for: screen)
        let targetFrame = action.targetRect(for: screenFrame)
        window.setFrame(targetFrame)
    }

    private func moveToDisplay(window: AccessibilityElement, currentFrame: CGRect, next: Bool) {
        guard let currentScreen = ScreenManager.screen(for: currentFrame) else { return }

        let targetScreen: NSScreen?
        if next {
            targetScreen = ScreenManager.nextScreen(from: currentScreen)
        } else {
            targetScreen = ScreenManager.previousScreen(from: currentScreen)
        }
        guard let target = targetScreen else { return }

        let sourceFrame = ScreenManager.axVisibleFrame(for: currentScreen)
        let targetScreenFrame = ScreenManager.axVisibleFrame(for: target)

        // Calculate proportional position on the target screen
        let relX = (currentFrame.origin.x - sourceFrame.origin.x) / sourceFrame.width
        let relY = (currentFrame.origin.y - sourceFrame.origin.y) / sourceFrame.height
        let relW = currentFrame.width / sourceFrame.width
        let relH = currentFrame.height / sourceFrame.height

        let newFrame = CGRect(
            x: targetScreenFrame.origin.x + relX * targetScreenFrame.width,
            y: targetScreenFrame.origin.y + relY * targetScreenFrame.height,
            width: relW * targetScreenFrame.width,
            height: relH * targetScreenFrame.height
        )

        window.setFrame(newFrame)
    }
}
