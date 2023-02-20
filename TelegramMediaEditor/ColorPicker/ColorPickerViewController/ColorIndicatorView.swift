import UIKit

// MARK: - ColorIndicatorView

class ColorIndicatorView: UIView {
    private lazy var colorLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    private var backgroundLayer: CALayer = {
        let layer = CALayer()
        return layer
    }()
    
    public var color: CGColor {
        get {
            return colorLayer.backgroundColor!
        }
        
        set {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            colorLayer.backgroundColor = newValue
            CATransaction.commit()
        }
    }
    
    // MARK: Initialization
    
    public init(_ color: CGColor) {
        super.init(frame: .zero)
        
        self.color = color
        
        buildViewHierarchy()
        setupLayout()
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        colorLayer.frame = bounds
        backgroundLayer.frame = bounds
        
        backgroundLayer.sublayers?.forEach { layer in
            layer.removeFromSuperlayer()
        }
        
        let firstRectangleBezierPath = UIBezierPath()
        firstRectangleBezierPath.move(to: CGPoint(x: 0, y: 0))
        firstRectangleBezierPath.addLine(to: CGPoint(x: backgroundLayer.bounds.width, y: 0))
        firstRectangleBezierPath.addLine(to: CGPoint(x: 0, y: backgroundLayer.bounds.height))
        
        let firstShapeLayer = CAShapeLayer()
        firstShapeLayer.fillColor = UIColor.black.cgColor
        firstShapeLayer.path = firstRectangleBezierPath.cgPath
        
        let secondRectangleBezierPath = UIBezierPath()
        secondRectangleBezierPath.move(to: CGPoint(x: 0, y: backgroundLayer.bounds.height))
        secondRectangleBezierPath.addLine(to: CGPoint(x: backgroundLayer.bounds.width, y: backgroundLayer.bounds.height))
        secondRectangleBezierPath.addLine(to: CGPoint(x: backgroundLayer.bounds.width, y: 0))
        
        let secondShapeLayer = CAShapeLayer()
        secondShapeLayer.fillColor = UIColor.white.cgColor
        secondShapeLayer.path = secondRectangleBezierPath.cgPath
        
        backgroundLayer.addSublayer(firstShapeLayer)
        backgroundLayer.addSublayer(secondShapeLayer)
    }
    
    // MARK: Private Functions
    
    private func buildViewHierarchy() {
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(colorLayer)
    }
    
    private func setupLayout() {
        
    }
    
    private func configureViews() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
}
