import SwiftUI

@main
struct KAWindowApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("KA Window", systemImage: "rectangle.split.2x1") {
            MenuBarView()
        }
        .menuBarExtraStyle(.menu)
    }
}
