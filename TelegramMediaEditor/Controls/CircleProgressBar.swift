import UIKit

final class CircleProgressBar: UIView {
    private lazy var shadowCircleShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        
        return shapeLayer
    }()
    private lazy var progressCircleShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        
        return shapeLayer
    }()
    
    private lazy var backgroundBlurVisualEffect: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        
        let visualEffect = UIVisualEffectView(effect: blurEffect)
        visualEffect.clipsToBounds = true
        
        return visualEffect
    }()
    
    public var progress: CGFloat = 0
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
            
//        overrideUserInterfaceStyle = .dark
        
        buildViewHierarchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let squareSideLength = min(bounds.height, bounds.width)
        
        backgroundBlurVisualEffect.frame = CGRect(x: 0, y: 0, width: squareSideLength, height: squareSideLength)
        backgroundBlurVisualEffect.layer.cornerRadius = backgroundBlurVisualEffect.bounds.height / 7
        
        shadowCircleShapeLayer.frame = backgroundBlurVisualEffect.frame
        progressCircleShapeLayer.frame = backgroundBlurVisualEffect.frame
        
        
        drawShadowCircleShapeLayer()
        drawProgressCircleShapeLayer()
    }
    
    // MARK: Private Functions
    
    private func buildViewHierarchy() {
        addSubview(backgroundBlurVisualEffect)
        layer.addSublayer(shadowCircleShapeLayer)
        layer.addSublayer(progressCircleShapeLayer)
    }
    
    private func drawShadowCircleShapeLayer() {
        let rect = shadowCircleShapeLayer.bounds
        
        let shadowCircleBezierPath = UIBezierPath()
        shadowCircleBezierPath.addArc(
            withCenter: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.height * 0.7 / 2,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: false
        )
        
        shadowCircleShapeLayer.fillColor = UIColor.clear.cgColor
        shadowCircleShapeLayer.lineWidth = rect.height * 0.075
        shadowCircleShapeLayer.strokeColor = UIColor.tertiarySystemBackground.cgColor
        shadowCircleShapeLayer.path = shadowCircleBezierPath.cgPath
    }
    
    private func drawProgressCircleShapeLayer() {
        let rect = progressCircleShapeLayer.bounds
        
        let indicatorCircleVezierPath = UIBezierPath()
        indicatorCircleVezierPath.addArc(
            withCenter: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.height * 0.7 / 2,
            startAngle: -.pi / 2,
            endAngle: 3 * .pi / 2,
            clockwise: true
        )
        
        progressCircleShapeLayer.fillColor = UIColor.clear.cgColor
        progressCircleShapeLayer.lineWidth = rect.height * 0.075
        progressCircleShapeLayer.lineCap = .round
        progressCircleShapeLayer.strokeEnd = 0.0
        progressCircleShapeLayer.strokeColor = UIColor.systemBlue.cgColor
        progressCircleShapeLayer.strokeEnd = progress.truncatingRemainder(dividingBy: 1)
        progressCircleShapeLayer.path = indicatorCircleVezierPath.cgPath
    }
    
    // MARK: Public Functions
    
    public func resetProgress(animated: Bool) {
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.toValue = -1
            animation.duration = 0.75
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            
            progressCircleShapeLayer.add(animation, forKey: nil)
        } else {
            progressCircleShapeLayer.removeAllAnimations()
            progressCircleShapeLayer.strokeEnd = -1
        }
        
        progress = 0
    }
 
    public func setProgress(to value: CGFloat, animated: Bool) {
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.toValue = value == 0 ? -1 : value
            animation.duration = 0.75
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            
            progressCircleShapeLayer.add(animation, forKey: nil)
        } else {
            progressCircleShapeLayer.removeAllAnimations()
            progressCircleShapeLayer.strokeEnd = value
        }
        
        progress = value
    }
    
}
