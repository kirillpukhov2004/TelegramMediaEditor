import UIKit

class Slider: UIControl {
    private lazy var trackLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        
        let bezierPath = UIBezierPath()
        
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
        shapeLayer.strokeColor = .clear
        
        return shapeLayer
    }()
    private lazy var thumbImage: UIImage = {
        let thumbRadius: CGFloat = 28
        let thumbFrame = CGSize(width: thumbRadius, height: thumbRadius)
        
        UIGraphicsBeginImageContextWithOptions(thumbFrame, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(.white)
        context?.fillEllipse(in: CGRect(origin: .zero, size: thumbFrame))
        
        guard let image =  UIGraphicsGetImageFromCurrentImageContext() else { fatalError() }
        return image
    }()
    private lazy var thumbImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = thumbImage
        return imageView
    }()
    
    public var delegate: SliderDelegate?
    
    public var minimumValue: Double = 0
    public var maximumValue: Double = 100
    public var step: Double = 0.1
    
    public var value: Double {
        let trackLength = bounds.width - leftTrackArcRadius - rightTrackArcRadius
        let sliderValue = minimumValue + (thumbPosition.x - leftTrackArcRadius + thumbImage.size.width / 2) / trackLength * (maximumValue - minimumValue)

        return min(round(sliderValue / step) * step, maximumValue)
    }
    
    private var thumbPosition: CGPoint = CGPoint()
    private var previousLocation: CGPoint = CGPoint()
    
    private let trackWidth: CGFloat = 240
    private let rightTrackArcRadius: CGFloat = 12
    private let leftTrackArcRadius: CGFloat = 2
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        buildViewHierarchy()
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        trackLayer.frame = CGRect(origin: .zero,
                                  size: CGSize(width: trackWidth,
                                               height: max(leftTrackArcRadius * 2, rightTrackArcRadius * 2)))
        
        thumbPosition.y = (trackLayer.frame.height - thumbImage.size.height) / 2
        thumbImageView.frame = CGRect(origin: thumbPosition, size: thumbImage.size)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let thumbPoint = thumbImageView.convert(point, from: self)
        if thumbImageView.point(inside: thumbPoint, with: event) {
            return self
        }
        return super.hitTest(point, with: event)
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchLocation = touch.location(in: self)
        
        if thumbImageView.frame.contains(touchLocation) {
            thumbImageView.isHighlighted = true
            previousLocation = touchLocation
        }
        
        return thumbImageView.isHighlighted
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchLocation = touch.location(in: self)
        
        let deltaX = touchLocation.x - previousLocation.x
        previousLocation = touchLocation
        
        let thumbXCenter = thumbImage.size.width / 2
        let leftLimit = leftTrackArcRadius - thumbXCenter
        let rightLimit = trackWidth - rightTrackArcRadius - thumbXCenter
        
        if thumbPosition.x + deltaX < leftLimit {
            thumbPosition.x = leftLimit
        } else if thumbPosition.x + deltaX > rightLimit {
            thumbPosition.x = rightLimit
        } else {
            thumbPosition.x += deltaX
        }
    
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        layoutSubviews()
        
        CATransaction.commit()

        delegate?.valueChanged(self)
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        thumbImageView.isHighlighted = false
    }
    
    private func buildViewHierarchy() {
        layer.addSublayer(trackLayer)
        addSubview(thumbImageView)
    }
    
    private func configureViews() {
        thumbPosition.x = leftTrackArcRadius - thumbImage.size.width / 2
    }
    
    public func setValue(to newValue: Double, animated: Bool = false) {
        let trackLength = bounds.width - leftTrackArcRadius - rightTrackArcRadius
        let thumbXPosition = (newValue - minimumValue) * trackLength / (maximumValue - minimumValue) + leftTrackArcRadius - thumbImage.size.width / 2
        thumbPosition.x = thumbXPosition
        layoutSubviews()
    }
}
