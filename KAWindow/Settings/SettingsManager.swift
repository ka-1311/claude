import Foundation
import CoreGraphics
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    private let defaults = UserDefaults.standard
    private let bindingsKey = "hotkeyBindings"

    @Published var bindings: [HotkeyBinding] = []
    @Published var launchAtLogin: Bool = false {
        didSet {
            LoginItemManager.setEnabled(launchAtLogin)
        }
    }

    private init() {}

    func load() {
        // Load bindings
        if let data = defaults.data(forKey: bindingsKey),
           let decoded = try? JSONDecoder().decode([HotkeyBinding].self, from: data) {
            bindings = decoded
        } else {
            bindings = WindowAction.allCases.map { $0.defaultBinding }
        }

        // Load launch at login status from system
        launchAtLogin = LoginItemManager.isEnabled

        // Sync to HotkeyManager
        HotkeyManager.shared.bindings = bindings
    }

    func save() {
        if let data = try? JSONEncoder().encode(bindings) {
            defaults.set(data, forKey: bindingsKey)
        }
        // Sync to HotkeyManager
        HotkeyManager.shared.bindings = bindings
    }

    func updateBinding(for action: WindowAction, keyCode: UInt16, modifiers: CGEventFlags) {
        if let index = bindings.firstIndex(where: { $0.action == action }) {
            bindings[index] = HotkeyBinding(keyCode: keyCode, modifiers: modifiers, action: action)
        }
        save()
    }

    func resetToDefaults() {
        bindings = WindowAction.allCases.map { $0.defaultBinding }
        save()
    }
}
