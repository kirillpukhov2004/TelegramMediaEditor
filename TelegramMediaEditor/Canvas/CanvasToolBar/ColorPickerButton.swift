import UIKit

// MARK: - ColorPickerButton

class ColorPickerButton: UIButton {
    private lazy var circleGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .conic
        let segments = 1024
        gradientLayer.colors = []
        for i in 0...segments {
            gradientLayer.colors?.append(UIColor(hue: CGFloat(i)/CGFloat(segments), saturation: 1, brightness: 1, alpha: 1).cgColor)
        }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        return gradientLayer
    }()
    private lazy var blackCircleLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.black.cgColor
        return layer
    }()
    private lazy var colorCircleLayer: CALayer = {
        let layer = CALayer()
        return layer
    }()
    
    public var color: CGColor? {
        get {
            return colorCircleLayer.backgroundColor
        }
        
        set {
            colorCircleLayer.backgroundColor = newValue
        }
    }
    
    // MARK: Initialization
    
    public init(_ color: CGColor) {
        super.init(frame: .zero)
        
        self.color = color
        
        buildViewHierarchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let sideLength = min(bounds.width, bounds.height)
        
        let colorCircleLayerSize = CGSize(width: sideLength * 0.576,
                                          height: sideLength * 0.576)
        let colorCircleLayerOrigin = CGPoint(x: bounds.width / 2 - colorCircleLayerSize.width / 2,
                                             y: bounds.height / 2 - colorCircleLayerSize.height / 2)
        colorCircleLayer.frame = CGRect(origin: colorCircleLayerOrigin,
                                        size: colorCircleLayerSize)
        colorCircleLayer.cornerRadius = colorCircleLayerSize.height / 2.0
        
        let blackCircleLayerSize = CGSize(width: sideLength * 0.818,
                                          height: sideLength * 0.818)
        let blackCircleOrigin = CGPoint(x: bounds.width / 2 - blackCircleLayerSize.width / 2,
                                        y: bounds.height / 2 - blackCircleLayerSize.height / 2)
        blackCircleLayer.frame = CGRect(origin: blackCircleOrigin,
                                        size: blackCircleLayerSize)
        blackCircleLayer.cornerRadius = blackCircleLayerSize.height / 2.0
        
        let circleGradientLayerSize = CGSize(width: sideLength,
                                             height: sideLength)
        let circleGradientLayerOrigin = CGPoint(x: bounds.width / 2 - circleGradientLayerSize.width / 2,
                                                y: bounds.height / 2 - circleGradientLayerSize.height / 2)
        circleGradientLayer.frame = CGRect(origin: circleGradientLayerOrigin,
                                           size: circleGradientLayerSize)
        circleGradientLayer.cornerRadius = circleGradientLayerSize.height / 2
    }
    
    // MARK: Private Functions
    
    private func buildViewHierarchy() {
        layer.addSublayer(circleGradientLayer)
        layer.addSublayer(blackCircleLayer)
        layer.addSublayer(colorCircleLayer)
    }
}
