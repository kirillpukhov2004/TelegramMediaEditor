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
    
    private var evenChessSegmentPattern: CGPatternDrawPatternCallback = { info, context in
        guard let info = info else { return }
        let segmentSideLength: CGFloat = unsafeBitCast(info, to: CGFloat.self)
        let squareSideLength: CGFloat = segmentSideLength / 2
        let firstRect = CGRect(x: squareSideLength, y: 0, width: squareSideLength, height: squareSideLength)
        let secondRect = CGRect(x: 0, y: squareSideLength, width: squareSideLength, height: squareSideLength)
        context.addRect(firstRect)
        context.addRect(secondRect)
        context.fillPath()
    }
    private var oddChessSegmentPattern: CGPatternDrawPatternCallback = { info, context in
        guard let info = info else { return }
        let segmentSideLength: CGFloat = unsafeBitCast(info, to: CGFloat.self)
        let squareSideLength: CGFloat = segmentSideLength / 2
        let firstRect = CGRect(x: 0, y: 0, width: squareSideLength, height: squareSideLength)
        let secondRect = CGRect(x: squareSideLength, y: squareSideLength, width: squareSideLength, height: squareSideLength)
        context.addRect(firstRect)
        context.addRect(secondRect)
        context.fillPath()
    }
    
    public var color: CGColor {
        return colorLayer.backgroundColor ?? UIColor.black.cgColor
    }
    
    // MARK: Initialization
    
    public init(_ selectedColor: CGColor) {
        super.init(frame: .zero)
        
        setColor(selectedColor)
        
        buildViewHierarchy()
        setupConstraints()
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
    
    private func setupConstraints() {
        
    }
    
    private func configureViews() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    // MARK: Public Functions
    
    public func setColor(_ color: CGColor) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        colorLayer.backgroundColor = color
        
        CATransaction.commit()
    }
}
