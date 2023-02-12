import UIKit

// MARK: - SavedColorsCollectionViewCell

class SavedColorsCollectionViewCell: UICollectionViewCell {
    private lazy var colorLayer: CALayer = {
        let layer = CALayer()
        return layer
    }()
    private lazy var backgroundLayer: CALayer = {
        let layer = CALayer()
        return layer
    }()
    
    public var isSelectedColor: Bool = false {
        didSet {
            if isSelectedColor {
                contentView.layer.mask = configureSelectedIndicatorLayer()
            } else {
                contentView.layer.mask = nil
            }
        }
    }
    
    public var color: CGColor {
        return colorLayer.backgroundColor ?? UIColor.black.cgColor
    }
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        buildViewHierarchy()
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.cornerRadius = contentView.bounds.width / 2
        backgroundLayer.frame = contentView.bounds
        colorLayer.frame = contentView.bounds
        
        if isSelectedColor {
            contentView.layer.mask = configureSelectedIndicatorLayer()
        }
        configureBackgroudLayer()
    }
    
    override func prepareForReuse() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        backgroundLayer.removeFromSuperlayer()
        colorLayer.backgroundColor = UIColor.clear.cgColor
        isSelectedColor = false
    }
    
    // MARK: Private Functions
    
    private func buildViewHierarchy() {
        contentView.layer.addSublayer(backgroundLayer)
        contentView.layer.addSublayer(colorLayer)
    }
    
    private func configureViews() {
        contentView.layer.masksToBounds = true
    }
    
    private func configureSelectedIndicatorLayer() -> CAShapeLayer {
        let squareBezierPath = UIBezierPath(rect: contentView.bounds)
        
        let firstCircleBezierPath = UIBezierPath(arcCenter: CGPoint(x: contentView.bounds.width / 2, y: contentView.bounds.height / 2),
                                                 radius: contentView.bounds.height * 0.80 / 2,
                                      startAngle: 0,
                                      endAngle: .pi * 2,
                                      clockwise: true)
        
        let secondCircleBezierPath = UIBezierPath(arcCenter: CGPoint(x: contentView.bounds.width / 2, y: contentView.bounds.height / 2),
                                                  radius: contentView.bounds.height * 0.60 / 2,
                                                  startAngle: 0,
                                                  endAngle: .pi * 2,
                                                  clockwise: true)
        
        let containerShapeLayer = CAShapeLayer()
        
        let mutablePath = CGMutablePath()
        mutablePath.addPath(firstCircleBezierPath.cgPath)
        mutablePath.addPath(secondCircleBezierPath.cgPath)
        mutablePath.addPath(squareBezierPath.cgPath)
        
        containerShapeLayer.fillRule = .evenOdd
        containerShapeLayer.fillColor = UIColor.black.cgColor
        containerShapeLayer.path = mutablePath
            
        return containerShapeLayer
    }
    
    private func configureBackgroudLayer() {
        backgroundLayer.sublayers?.removeAll()
        
        backgroundLayer.frame = contentView.bounds
        
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
    
    // MARK: Public Functions
    
    public func configure(withColor color: CGColor, isButton: Bool = false) {
        colorLayer.backgroundColor = color

        if !isButton {
            contentView.layer.insertSublayer(backgroundLayer, at: 0)
            
            if isSelectedColor {
                contentView.layer.mask = configureSelectedIndicatorLayer()
            }
        }
    }
}
