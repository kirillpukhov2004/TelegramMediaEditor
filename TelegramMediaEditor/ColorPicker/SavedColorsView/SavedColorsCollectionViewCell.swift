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
        
        configureBackgroudLayer()
    }
    
    override func prepareForReuse() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        backgroundLayer.removeFromSuperlayer()
        colorLayer.backgroundColor = UIColor.clear.cgColor
    }
    
    // MARK: Private Functions
    
    private func buildViewHierarchy() {
        contentView.layer.addSublayer(backgroundLayer)
        contentView.layer.addSublayer(colorLayer)
    }
    
    private func configureViews() {
        contentView.layer.masksToBounds = true
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
        }
    }
    
    public func getColor() -> CGColor {
        return colorLayer.backgroundColor!
    }
}
