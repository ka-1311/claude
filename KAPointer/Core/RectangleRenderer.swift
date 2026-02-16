import AppKit

class RectangleRenderer: NSView {
    private var dragStartPoint: NSPoint?
    private var currentRect: NSRect?
    private let overlayOpacity: CGFloat = 0.4
    private let rectangleBorderColor: NSColor = .systemYellow
    private let rectangleBorderWidth: CGFloat = 3.0

    override init(frame: NSRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override var acceptsFirstResponder: Bool { true }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func mouseDown(with event: NSEvent) {
        dragStartPoint = convert(event.locationInWindow, from: nil)
        currentRect = nil
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        guard let start = dragStartPoint else { return }
        let current = convert(event.locationInWindow, from: nil)

        let x = min(start.x, current.x)
        let y = min(start.y, current.y)
        let w = abs(current.x - start.x)
        let h = abs(current.y - start.y)
        currentRect = NSRect(x: x, y: y, width: w, height: h)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        // Keep rectangle visible until mode is deactivated (Cmd keys released)
        dragStartPoint = nil
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        // Draw semi-transparent dark overlay
        context.setFillColor(NSColor.black.withAlphaComponent(overlayOpacity).cgColor)
        context.fill(bounds)

        // If there's a selected rectangle, cut it clear and draw a border
        if let rect = currentRect, rect.width > 1, rect.height > 1 {
            // Clear the rectangle area to show content beneath
            context.setBlendMode(.clear)
            context.fill(rect)

            // Draw border around the rectangle
            context.setBlendMode(.normal)
            context.setStrokeColor(rectangleBorderColor.cgColor)
            context.setLineWidth(rectangleBorderWidth)
            context.stroke(rect)
        }
    }
}
