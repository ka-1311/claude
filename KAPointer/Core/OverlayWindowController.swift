import AppKit

class OverlayWindowController {
    static let shared = OverlayWindowController()

    private var overlayWindows: [NSWindow] = []
    private var mouseTracker: MouseTracker?
    private var screenObserver: Any?

    enum Mode {
        case none, spotlight, rectangle
    }
    private(set) var currentMode: Mode = .none

    private init() {
        // Monitor screen configuration changes
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self, self.currentMode != .none else { return }
            let mode = self.currentMode
            self.hideOverlay()
            switch mode {
            case .spotlight: self.showSpotlight()
            case .rectangle: self.showRectangle()
            case .none: break
            }
        }
    }

    func showSpotlight() {
        if currentMode == .spotlight { return }
        if currentMode == .rectangle {
            teardownRenderers()
        }
        if overlayWindows.isEmpty {
            createOverlayWindows()
        }
        setupSpotlight()
        currentMode = .spotlight
    }

    func showRectangle() {
        if currentMode == .rectangle { return }
        if currentMode == .spotlight {
            teardownRenderers()
        }
        if overlayWindows.isEmpty {
            createOverlayWindows()
        }
        setupRectangle()
        currentMode = .rectangle
    }

    func hideOverlay() {
        teardownRenderers()
        destroyOverlayWindows()
        currentMode = .none
    }

    // MARK: - Window Management

    private func createOverlayWindows() {
        for screen in NSScreen.screens {
            let window = NSWindow(
                contentRect: screen.frame,
                styleMask: .borderless,
                backing: .buffered,
                defer: false,
                screen: screen
            )
            window.level = .screenSaver
            window.isOpaque = false
            window.backgroundColor = .clear
            window.ignoresMouseEvents = true
            window.hasShadow = false
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.hidesOnDeactivate = false

            window.orderFrontRegardless()
            overlayWindows.append(window)
        }
    }

    private func destroyOverlayWindows() {
        for window in overlayWindows {
            window.orderOut(nil)
        }
        overlayWindows.removeAll()
    }

    // MARK: - Spotlight

    private func setupSpotlight() {
        for window in overlayWindows {
            guard let contentView = window.contentView else { continue }
            let renderer = SpotlightRenderer(frame: contentView.bounds)
            renderer.autoresizingMask = [.width, .height]
            contentView.addSubview(renderer)
            window.ignoresMouseEvents = true
        }

        mouseTracker = MouseTracker()
        mouseTracker?.onMouseMoved = { [weak self] location in
            self?.updateSpotlightPosition(location)
        }
        mouseTracker?.start()

        // Set initial position
        updateSpotlightPosition(NSEvent.mouseLocation)
    }

    private func updateSpotlightPosition(_ screenLocation: NSPoint) {
        for window in overlayWindows {
            let localPoint = window.convertPoint(fromScreen: screenLocation)
            if let renderer = window.contentView?.subviews.first as? SpotlightRenderer {
                renderer.spotlightCenter = localPoint
            }
        }
    }

    // MARK: - Rectangle

    private func setupRectangle() {
        for window in overlayWindows {
            guard let contentView = window.contentView else { continue }
            let renderer = RectangleRenderer(frame: contentView.bounds)
            renderer.autoresizingMask = [.width, .height]
            contentView.addSubview(renderer)
            // Rectangle mode needs mouse events
            window.ignoresMouseEvents = false
        }
    }

    // MARK: - Teardown

    private func teardownRenderers() {
        mouseTracker?.stop()
        mouseTracker = nil
        for window in overlayWindows {
            window.contentView?.subviews.forEach { $0.removeFromSuperview() }
            window.ignoresMouseEvents = true
        }
    }
}
