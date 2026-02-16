import SwiftUI

@main
struct KAPointerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("KA Pointer", systemImage: "scope") {
            MenuBarView()
        }
        .menuBarExtraStyle(.menu)
    }
}
