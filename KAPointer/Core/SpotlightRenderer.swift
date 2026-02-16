import AppKit
import QuartzCore

class SpotlightRenderer: NSView {
    var spotlightCenter: NSPoint = .zero {
        didSet { updateMask() }
    }
    var spotlightRadius: CGFloat = 60.0

    private let overlayLayer = CALayer()
    private let maskLayer = CAShapeLayer()

    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
        setupLayers()
    }

    private func setupLayers() {
        overlayLayer.backgroundColor = NSColor.black.withAlphaComponent(0.5).cgColor
        overlayLayer.frame = bounds
        overlayLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        layer?.addSublayer(overlayLayer)

        // evenOdd: fill the whole rect, subtract the circle = spotlight hole
        maskLayer.fillRule = .evenOdd
        maskLayer.fillColor = NSColor.white.cgColor
        overlayLayer.mask = maskLayer
    }

    private func updateMask() {
        let path = CGMutablePath()
        path.addRect(bounds)
        path.addEllipse(in: CGRect(
            x: spotlightCenter.x - spotlightRadius,
            y: spotlightCenter.y - spotlightRadius,
            width: spotlightRadius * 2,
            height: spotlightRadius * 2
        ))
        // Disable implicit animation for smooth tracking
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        maskLayer.path = path
        CATransaction.commit()
    }

    override func layout() {
        super.layout()
        overlayLayer.frame = bounds
        updateMask()
    }
}
