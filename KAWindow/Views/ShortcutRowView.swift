import SwiftUI
import CoreGraphics

struct ShortcutRowView: View {
    let action: WindowAction
    @Binding var binding: HotkeyBinding
    let onUpdate: (UInt16, CGEventFlags) -> Void

    var body: some View {
        HStack {
            Text(action.displayName)
                .frame(width: 180, alignment: .leading)

            Spacer()

            ShortcutRecorderView(
                keyCode: binding.keyCode,
                modifiers: binding.eventFlags,
                onRecord: { keyCode, modifiers in
                    onUpdate(keyCode, modifiers)
                }
            )
            .frame(width: 180)
        }
        .padding(.vertical, 4)
    }
}
