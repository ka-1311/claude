import SwiftUI

struct MenuBarView: View {
    var body: some View {
        Group {
            Section {
                Text("Spotlight: Hold Left+Right Cmd")
                    .font(.caption)
                Text("Rectangle: Hold Left+Right Cmd+Shift")
                    .font(.caption)
            }

            Divider()

            Button("Quit KA Pointer") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
    }
}
