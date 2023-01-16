import UIKit

class ColorPicker: UIView {
    private var colorCircleLayer: CALayer
    private var gradientCircleLayer: CAGradientLayer
    private var blackCircleLayer: CALayer
    
    public var selectedColor: CGColor
    
    private var layersHeight: CGFloat {
        return min(bounds.height, bounds.width)
    }
    private var layersCenter: CGPoint {
        return CGPoint(x: bounds.width - layersHeight / 2.0,
                       y: bounds.height - layersHeight / 2.0)
    }
    
    private let innerRadius: CGFloat = 27.0
    private let outterRadius: CGFloat = 3.0
    
    init() {
        selectedColor = CGColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        
        colorCircleLayer = CALayer()
        colorCircleLayer.backgroundColor = selectedColor
    
        gradientCircleLayer = CAGradientLayer()
        gradientCircleLayer.type = .conic
        let segments = 1024
        gradientCircleLayer.colors = []
        for i in 0...segments {
            gradientCircleLayer.colors?.append(UIColor(hue: CGFloat(i)/CGFloat(segments), saturation: 1, brightness: 1, alpha: 1).cgColor)
        }
        gradientCircleLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientCircleLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        
        blackCircleLayer = CALayer()
        blackCircleLayer.backgroundColor = .black
        
        super.init(frame: .zero)
        
        layer.addSublayer(colorCircleLayer)
        layer.insertSublayer(blackCircleLayer, below: colorCircleLayer)
        layer.insertSublayer(gradientCircleLayer, below: blackCircleLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        colorCircleLayer.frame = CGRect(origin: CGPoint(x: bounds.width / 2.0 - (frame.height - 14.0) / 2.0,
                                                        y: bounds.height / 2.0 - (frame.height - 14.0) / 2.0),
                                        size: CGSize(width: frame.height - 14.0,
                                                     height: frame.height - 14.0))
        colorCircleLayer.cornerRadius = colorCircleLayer.frame.height / 2.0
        
        let borderWidth = 3.0
        let blackCircleLayerHeight = bounds.width - (bounds.height - colorCircleLayer.frame.height) + 2.0 * borderWidth
        blackCircleLayer.frame = CGRect(origin: CGPoint(x: bounds.width / 2.0 - blackCircleLayerHeight / 2.0,
                                                        y: bounds.height / 2.0 - blackCircleLayerHeight / 2.0),
                                        size: CGSize(width: blackCircleLayerHeight,
                                                     height: blackCircleLayerHeight))
        blackCircleLayer.cornerRadius = blackCircleLayerHeight / 2.0
        
        gradientCircleLayer.frame = bounds
        gradientCircleLayer.cornerRadius = gradientCircleLayer.frame.height / 2
    }
}
