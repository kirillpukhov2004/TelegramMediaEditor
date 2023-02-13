import UIKit

// MARK: - Constants

fileprivate enum Constants {
    static let sliderSize = CGSize(width: 269, height: 36)
    static let sliderThumbSize = CGSize(width: 29, height: 29)
}

// MARK: - OpacitySlider

class OpacitySlider: Slider {
    public var color: CGColor {
        didSet {
            updateState()
        }
    }
    
    private var opacitySliderTrackLayer: CALayer {
        let layer = CALayer()
        layer.frame.size = CGSize(width: Constants.sliderSize.width, height: Constants.sliderSize.height)
        
        let chessBoardImage = getChessBoardImage(
            ofSize: layer.bounds.size,
            squaresPerCollumn: 3,
            evenSquareColor: CGColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5),
            oddSquareColor: CGColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0)
        )
        let chessBoardImageLayer = CALayer()
        chessBoardImageLayer.contents = chessBoardImage.cgImage
        chessBoardImageLayer.frame = layer.bounds
        layer.addSublayer(chessBoardImageLayer)
        
        let backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.colors = [UIColor.clear.cgColor, color.copy(alpha: 1)!]
        backgroundGradientLayer.locations = [0, 1]
        backgroundGradientLayer.transform = CATransform3DMakeRotation(-(.pi / 2), 0, 0, 1)
        backgroundGradientLayer.frame = layer.bounds
        layer.addSublayer(backgroundGradientLayer)
        
        layer.cornerRadius = Constants.sliderSize.height / 2
        layer.masksToBounds = true
        
        return layer
    }
    
    private var opacitySliderThumbLayer: CALayer {
        let horizontalPadding: CGFloat = (Constants.sliderSize.height - Constants.sliderThumbSize.height) / 2
        let layer = CALayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.frame.size = CGSize(width: Constants.sliderThumbSize.width + horizontalPadding * 2, height: Constants.sliderThumbSize.width)
        
        let firstShapeLayer = CAShapeLayer()
        firstShapeLayer.fillColor = UIColor.white.cgColor
        let firstBezierPath = UIBezierPath(arcCenter: CGPoint(x: Constants.sliderThumbSize.width / 2 + horizontalPadding, y: Constants.sliderThumbSize.height / 2),
                                           radius: Constants.sliderThumbSize.width / 2,
                                           startAngle: 0, endAngle: 2 * .pi,
                                           clockwise: true)
        firstShapeLayer.path = firstBezierPath.cgPath
        firstShapeLayer.frame = layer.bounds
        
        let secondShapeLayer = CAShapeLayer()
        secondShapeLayer.fillColor = color
        let secondBezierPath = UIBezierPath(arcCenter: CGPoint(x: Constants.sliderThumbSize.width / 2 + horizontalPadding, y: Constants.sliderThumbSize.height / 2),
                                            radius: Constants.sliderThumbSize.width / 2 - 3,
                                           startAngle: 0, endAngle: 2 * .pi,
                                           clockwise: true)
        secondShapeLayer.path = secondBezierPath.cgPath
        secondShapeLayer.frame = layer.bounds
        
        layer.addSublayer(firstShapeLayer)
        layer.addSublayer(secondShapeLayer)
        return layer
    }
    
    public init(withColor color: CGColor) {
        self.color = color
        
        super.init()
        
        minimumValue = 0
        maximumValue = 1
        step = 0.01
        
        updateState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private Functions
    
    private func updateState() {
        value = color.alpha
        setThumbLayer(to: opacitySliderThumbLayer)
        setTrackLayer(to: opacitySliderTrackLayer)
    }
    
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
    
    private func getChessBoardImage(
        ofSize size: CGSize,
        squaresPerRow: Int? = nil,
        squaresPerCollumn: Int? = nil,
        evenSquareColor: CGColor = UIColor.black.cgColor,
        oddSquareColor: CGColor = UIColor.white.cgColor
    ) -> UIImage {
        let squareSideLength: CGFloat  = {
            if let squaresPerRow = squaresPerRow {
                return size.width / squaresPerRow
            } else if let squaresPerCollumn = squaresPerCollumn {
                return size.height / squaresPerCollumn
            } else {
                return size.width / 16
            }
        }()
        let segmentSideLength: CGFloat = squareSideLength * 2
        let segmentSideLengthRawPointer = unsafeBitCast(segmentSideLength, to: UnsafeMutableRawPointer.self)
        
        var evenPatternCallbacks = CGPatternCallbacks(
            version: 0,
            drawPattern: evenChessSegmentPattern,
            releaseInfo: nil
        )
        var oddPatternCallbacks = CGPatternCallbacks(
            version: 0,
            drawPattern: oddChessSegmentPattern,
            releaseInfo: nil
        )
        
        let evenPattern = CGPattern(
            info: segmentSideLengthRawPointer,
            bounds: CGRect(origin: .zero, size: CGSize(width: segmentSideLength, height: segmentSideLength)),
            matrix: .identity,
            xStep: segmentSideLength,
            yStep: segmentSideLength,
            tiling: .constantSpacing,
            isColored: false,
            callbacks: &evenPatternCallbacks
        )!
        let oddPattern = CGPattern(
            info: segmentSideLengthRawPointer,
            bounds: CGRect(origin: .zero, size: CGSize(width: segmentSideLength, height: segmentSideLength)),
            matrix: .identity,
            xStep: segmentSideLength,
            yStep: segmentSideLength,
            tiling: .constantSpacing,
            isColored: false,
            callbacks: &oddPatternCallbacks
        )!

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let patternColorSpace = CGColorSpace(patternBaseSpace: colorSpace)!
        context.setFillColorSpace(patternColorSpace)
        
        let rect = CGRect(origin: .zero, size: size)
        
        let evenFillColorComponents: [CGFloat] = [evenSquareColor.red, evenSquareColor.green, evenSquareColor.blue, evenSquareColor.alpha]
        context.setFillPattern(evenPattern, colorComponents: evenFillColorComponents)
        context.fill(rect)
        
        let oddFillColorComponents: [CGFloat] = [oddSquareColor.red, oddSquareColor.green, oddSquareColor.blue, oddSquareColor.alpha]
        context.setFillPattern(oddPattern, colorComponents: oddFillColorComponents)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
}
