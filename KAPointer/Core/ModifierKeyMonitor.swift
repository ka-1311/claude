import CoreGraphics
import AppKit

class ModifierKeyMonitor {
    static let shared = ModifierKeyMonitor()

    private(set) var isRunning = false
    private(set) var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    private var leftCmdDown = false
    private var rightCmdDown = false
    private var bothCmdWasDown = false

    enum PointerMode: Equatable {
        case none
        case spotlight
        case rectangle
    }

    private(set) var activeMode: PointerMode = .none

    private init() {}

    func start() {
        guard eventTap == nil else { return }

        let eventMask: CGEventMask = (1 << CGEventType.flagsChanged.rawValue)
        let userInfo = Unmanaged.passUnretained(self).toOpaque()

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: eventMask,
            callback: modifierEventCallback,
            userInfo: userInfo
        ) else {
            NSLog("[KA Pointer] Failed to create CGEvent tap")
            return
        }

        self.eventTap = tap
        self.runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        isRunning = true
        NSLog("[KA Pointer] Modifier key monitor started")
    }

    func stop() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            if let source = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
            }
        }
        eventTap = nil
        runLoopSource = nil
        isRunning = false
    }

    func reEnable() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
        } else {
            start()
        }
    }

    func handleFlagsChanged(_ event: CGEvent) {
        let keycode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
        let flags = event.flags

        // Track left/right Cmd individually via keycode
        // Left Cmd = 55 (0x37), Right Cmd = 54 (0x36)
        if keycode == 0x37 { // Left Cmd
            leftCmdDown = flags.contains(.maskCommand)
        } else if keycode == 0x36 { // Right Cmd
            rightCmdDown = flags.contains(.maskCommand)
        }

        // Safety: if maskCommand is not set at all, both must be released
        if !flags.contains(.maskCommand) {
            leftCmdDown = false
            rightCmdDown = false
        }

        let bothCmdNow = leftCmdDown && rightCmdDown
        let shift = flags.contains(.maskShift)

        // Detect the moment both Cmds become pressed (rising edge)
        if bothCmdNow && !bothCmdWasDown {
            let requestedMode: PointerMode = shift ? .rectangle : .spotlight

            if activeMode == requestedMode {
                // Same mode -> toggle off
                NSLog("[KA Pointer] Toggle OFF: %@", "\(activeMode)")
                activeMode = .none
                DispatchQueue.main.async {
                    OverlayWindowController.shared.hideOverlay()
                }
            } else {
                // Different mode or none -> activate
                NSLog("[KA Pointer] Toggle ON: %@", "\(requestedMode)")
                activeMode = requestedMode
                DispatchQueue.main.async {
                    switch requestedMode {
                    case .spotlight:
                        OverlayWindowController.shared.showSpotlight()
                    case .rectangle:
                        OverlayWindowController.shared.showRectangle()
                    case .none:
                        break
                    }
                }
            }
        }

        bothCmdWasDown = bothCmdNow
    }
}

private func modifierEventCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let tap = ModifierKeyMonitor.shared.eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
        }
        return Unmanaged.passUnretained(event)
    }

    if type == .flagsChanged, let userInfo = userInfo {
        let monitor = Unmanaged<ModifierKeyMonitor>.fromOpaque(userInfo).takeUnretainedValue()
        monitor.handleFlagsChanged(event)
    }
    return Unmanaged.passUnretained(event)
}
