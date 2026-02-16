import SwiftUI

struct MenuBarView: View {
    var body: some View {
        Group {
            Button("Left Half") { WindowManager.shared.execute(.leftHalf) }
            Button("Right Half") { WindowManager.shared.execute(.rightHalf) }
            Button("Top Right") { WindowManager.shared.execute(.topRightQuarter) }
            Button("Bottom Right") { WindowManager.shared.execute(.bottomRightQuarter) }

            Divider()

            Button("Left Two Thirds") { WindowManager.shared.execute(.leftTwoThirds) }
            Button("Right One Third") { WindowManager.shared.execute(.rightOneThird) }

            Divider()

            Button("Maximize") { WindowManager.shared.execute(.maximize) }
            Button("Next Display") { WindowManager.shared.execute(.moveToNextDisplay) }
            Button("Previous Display") { WindowManager.shared.execute(.moveToPreviousDisplay) }

            Divider()

            Button("Preferences...") {
                SettingsWindowController.shared.showSettings()
            }
            .keyboardShortcut(",", modifiers: .command)

            Divider()

            Button("Quit KA Window") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
    }
}
