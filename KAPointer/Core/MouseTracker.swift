import AppKit

class MouseTracker {
    var onMouseMoved: ((NSPoint) -> Void)?

    private var globalMonitor: Any?
    private var localMonitor: Any?

    func start() {
        let eventTypes: NSEvent.EventTypeMask = [.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged]

        // Global monitor: when our app is NOT focused
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: eventTypes) { [weak self] _ in
            self?.onMouseMoved?(NSEvent.mouseLocation)
        }

        // Local monitor: when our app IS focused (e.g., overlay window in rectangle mode)
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: eventTypes) { [weak self] event in
            self?.onMouseMoved?(NSEvent.mouseLocation)
            return event
        }
    }

    func stop() {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }
}
