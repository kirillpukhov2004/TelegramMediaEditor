import UIKit

// MARK: - Slider

class Slider: UIControl {
    private lazy var trackLayer: CALayer = defaultTrackLayer
    private lazy var thumbLayer: CALayer = defaultThumbLayer
    
    private var defaultTrackLayer: CALayer {
        let shapeLayer = CAShapeLayer()
        
        let bezierPath = UIBezierPath()
        
        let leftTrackArcRadius: CGFloat = 4 / 2
        let rightTrackArcRadius: CGFloat = 24 / 2
        let trackWidth: CGFloat = 240
        
        // Left Arc
        let leftArcCenter = CGPoint(x: leftTrackArcRadius,
                                    y: rightTrackArcRadius)
        bezierPath.addArc(withCenter: leftArcCenter,
                          radius: leftTrackArcRadius,
                          startAngle: .pi / 2,
                          endAngle: 3 * .pi / 2,
                          clockwise: true)
        
        // Bottom Line
        bezierPath.move(to: CGPoint(x: leftTrackArcRadius,
                                    y: leftTrackArcRadius + rightTrackArcRadius))
        bezierPath.addLine(to: CGPoint(x: trackWidth - leftTrackArcRadius - rightTrackArcRadius,
                                       y: rightTrackArcRadius * 2))
        
        // Right Arc
        let rightArcCenter = CGPoint(x: trackWidth - rightTrackArcRadius,
                                     y: rightTrackArcRadius)
        bezierPath.addArc(withCenter: rightArcCenter,
                          radius: rightTrackArcRadius,
                          startAngle: .pi / 2,
                          endAngle: 3 * .pi / 2,
                          clockwise: false)
        
        // Top Line
        bezierPath.addLine(to: CGPoint(x: leftTrackArcRadius,
                                       y: rightTrackArcRadius - leftTrackArcRadius))
        
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.fillColor = CGColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2)
        shapeLayer.strokeColor = UIColor.clear.cgColor
        
        shapeLayer.frame.size = CGSize(width: trackWidth, height: rightTrackArcRadius * 2)
        
        return shapeLayer
    }
    private var defaultThumbLayer: CALayer {
        let shapeLayer = CAShapeLayer()
        
        let thumbDiameter: CGFloat = 28
        
        let bezierPath = UIBezierPath()
        bezierPath.addArc(withCenter: CGPoint(x: thumbDiameter / 2, y: thumbDiameter / 2),
                          radius: thumbDiameter / 2,
                          startAngle: 0,
                          endAngle: .pi * 2,
                          clockwise: true)
        
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.fillColor = UIColor.white.cgColor
        
        shapeLayer.frame.size = CGSize(width: 28, height: 28)
        
        return shapeLayer
    }
    
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(panGestureRecognizerAction(_:)))
        return panGestureRecognizer
    }()
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(tapGestureRecognizerAction(_:)))
        return tapGestureRecognizer
    }()
    
    public var minimumValue: Double = 0
    public var maximumValue: Double = 100
    public var step: Double = 1
    public var value: Double {
        get {
            let trackWidth: CGFloat = trackLayer.frame.width - thumbLayer.frame.width
            let thumbCenterXCoordinate: CGFloat = currentTouchXCoordinate
            let thumbXNormalizedCoordinate: CGFloat = thumbCenterXCoordinate / trackWidth
            return round(min(minimumValue + thumbXNormalizedCoordinate * (maximumValue - minimumValue), maximumValue) / step) * step
        }
        
        set {
            updateThumbPosition(to: newValue)
        }
    }
    
    private var currentTouchXCoordinate: CGFloat!
    private var previousTouchXCoordinate: CGFloat!
    
    // MARK: Initialization
    
    public init() {
        super.init(frame: .zero)
        
        self.value = self.maximumValue
        
        buildViewHierarchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        trackLayer.frame.origin = CGPoint(x: layer.bounds.midX - trackLayer.frame.width / 2,
                                          y: layer.bounds.midY - trackLayer.frame.height / 2)
        
        if currentTouchXCoordinate == nil {
            currentTouchXCoordinate = trackLayer.frame.minX
        }
        
        thumbLayer.frame.origin = CGPoint(x: currentTouchXCoordinate,
                                          y: layer.bounds.midY - thumbLayer.frame.height / 2)
    }
    
    // MARK: Touch Processing
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let thumbLayerPoint = thumbLayer.convert(point, from: layer)
        if thumbLayer.contains(thumbLayerPoint) {
            return self
        }
        
        return super.hitTest(point, with: event)
    }
    
    // MARK: Actions
    
    @objc func panGestureRecognizerAction(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            moveThumbHorizontaly(to: sender.location(in: self))
        default:
            return
        }
    }
    
    @objc func tapGestureRecognizerAction(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            moveThumbHorizontaly(to: sender.location(in: self))
        }
    }
    
    
    // MARK: Private Functions
    
    private func buildViewHierarchy() {
        layer.addSublayer(trackLayer)
        layer.addSublayer(thumbLayer)
        
        addGestureRecognizer(panGestureRecognizer)
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func updateThumbPosition(to value: Double) {
        let newValue = min(max(minimumValue, value), maximumValue)
        
        let trackWidth: CGFloat = trackLayer.frame.width - thumbLayer.frame.width
        currentTouchXCoordinate = (newValue - minimumValue) / (maximumValue - minimumValue) * trackWidth
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func moveThumbHorizontaly(to point: CGPoint) {
        let thumbRadius = thumbLayer.frame.width / 2
        let trackLeftXCoordinateLimit: CGFloat = trackLayer.frame.minX + thumbRadius
        let trackRightXCoordinateLimit: CGFloat = trackLayer.frame.maxX - thumbRadius
        
        let deltaX = point.x - thumbLayer.frame.minX - thumbRadius

        let thumbLayerNewCenterXPosition = thumbLayer.frame.origin.x + thumbRadius + deltaX
        if thumbLayerNewCenterXPosition <= trackLeftXCoordinateLimit {
            currentTouchXCoordinate = trackLeftXCoordinateLimit - thumbRadius
        } else if thumbLayerNewCenterXPosition >= trackRightXCoordinateLimit {
            currentTouchXCoordinate = trackRightXCoordinateLimit - thumbRadius
        } else {
            currentTouchXCoordinate += deltaX
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        setNeedsLayout()
        layoutIfNeeded()

        CATransaction.commit()

        sendActions(for: .valueChanged)
    }
    
    // MARK: Public Functions
    
    public func setTrackLayer(to newTrackLayer: CALayer) {
        let currentValue = value
        trackLayer.removeFromSuperlayer()
        trackLayer = newTrackLayer
        layer.insertSublayer(trackLayer, below: thumbLayer)
        updateThumbPosition(to: currentValue)
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    public func setThumbLayer(to newThumbLayer: CALayer) {
        let currentValue = value
        thumbLayer.removeFromSuperlayer()
        thumbLayer = newThumbLayer
        layer.insertSublayer(thumbLayer, above: trackLayer)
        updateThumbPosition(to: currentValue)
        
        setNeedsLayout()
        layoutIfNeeded()
    }
}
