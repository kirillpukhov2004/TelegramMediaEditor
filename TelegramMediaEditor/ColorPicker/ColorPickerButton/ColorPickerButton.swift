import UIKit

// MARK: - ColorPickerButton

#warning("Rebuild ColorPickerButton using UIButton superclass")
class ColorPickerButton: UIView {
    private lazy var colorCircleLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = selectedColor
        return layer
    }()
    private lazy var circlyGradientLayer: CAGradientLayer = {
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
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(selfPressed))
        return tapGestureRecognizer
    }()
    
    public var selectedColor: CGColor {
        willSet(newColor) {
            colorCircleLayer.backgroundColor = newColor
        }
    }
    
    private var layersHeight: CGFloat {
        return min(bounds.height, bounds.width)
    }
    private var layersCenter: CGPoint {
        return CGPoint(x: bounds.width - layersHeight / 2.0,
                       y: bounds.height - layersHeight / 2.0)
    }
    
    public var delegate: ColorPickerButtonDelegate?
    
    // MARK: Initialization
    
    public init(_ initialColor: CGColor) {
        self.selectedColor = initialColor
        
        super.init(frame: .zero)
        
        buildViewHierarchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
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
        
        circlyGradientLayer.frame = bounds
        circlyGradientLayer.cornerRadius = circlyGradientLayer.frame.height / 2
    }
    
    // MARK: Actions
    
    @objc private func selfPressed() {
        guard let rootVC = self.window?.rootViewController else { return }
        let colorPickerViewController = ColorPickerViewController(selectedColor)
        colorPickerViewController.delegate = self
        rootVC.present(colorPickerViewController, animated: true)
    }
    
    // MARK: Private Functions
    
    private func buildViewHierarchy() {
        layer.addSublayer(colorCircleLayer)
        layer.insertSublayer(blackCircleLayer, below: colorCircleLayer)
        layer.insertSublayer(circlyGradientLayer, below: blackCircleLayer)
        
        addGestureRecognizer(tapGestureRecognizer)
    }
    
}

// MARK: - : ColorPickerViewControllerDelegate

extension ColorPickerButton: ColorPickerViewControllerDelegate {
    func colorPickerViewControllerColorChanged(_ colorPickerViewController: ColorPickerViewController) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        selectedColor = colorPickerViewController.color
        CATransaction.commit()
        delegate?.colorChanged(self)
    }
}
