import SwiftUI

struct PreferencesView: View {
    @ObservedObject var settings = SettingsManager.shared
    @ObservedObject var permission = AccessibilityPermission.shared

    var body: some View {
        TabView {
            ShortcutsTab(settings: settings)
                .tabItem { Label("Shortcuts", systemImage: "keyboard") }

            GeneralTab(settings: settings, permission: permission)
                .tabItem { Label("General", systemImage: "gear") }

            AboutTab()
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 500, height: 400)
        .padding(.top, 8)
    }
}

// MARK: - Shortcuts Tab

struct ShortcutsTab: View {
    @ObservedObject var settings: SettingsManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            List {
                ForEach(Array(WindowAction.allCases)) { action in
                    if let bindingIndex = settings.bindings.firstIndex(where: { $0.action == action }) {
                        ShortcutRowView(
                            action: action,
                            binding: $settings.bindings[bindingIndex],
                            onUpdate: { keyCode, modifiers in
                                settings.updateBinding(for: action, keyCode: keyCode, modifiers: modifiers)
                            }
                        )
                    }
                }
            }

            HStack {
                Spacer()
                Button("Reset to Defaults") {
                    settings.resetToDefaults()
                }
                .padding(.trailing, 16)
                .padding(.bottom, 12)
            }
        }
    }
}

// MARK: - General Tab

struct GeneralTab: View {
    @ObservedObject var settings: SettingsManager
    @ObservedObject var permission: AccessibilityPermission

    var body: some View {
        Form {
            Section {
                Toggle("Launch at Login", isOn: $settings.launchAtLogin)
            }

            Section {
                HStack {
                    Text("Accessibility Permission:")
                    Spacer()
                    if permission.isGranted {
                        Text("Granted")
                            .foregroundColor(.green)
                    } else {
                        Text("Not Granted")
                            .foregroundColor(.red)
                        Button("Open System Settings") {
                            permission.requestAccess()
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - About Tab

struct AboutTab: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "rectangle.split.2x1")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            Text("KA Window")
                .font(.title)
                .fontWeight(.bold)
            Text("Version 1.0.0")
                .foregroundColor(.secondary)
            Text("A lightweight window manager for macOS.")
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
