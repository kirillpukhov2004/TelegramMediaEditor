import UIKit

// MARK: - CanvasView

class CanvasView: UIView {    
    private lazy var strokeGestureRecognizer: StrokeGestureRecognizer = {
        let strokeGestureRecognizer = StrokeGestureRecognizer()
        strokeGestureRecognizer.strokeDelegate = self
        return strokeGestureRecognizer
    }()
    
    public var tool: Tool
    private(set) var strokes: [Stroke] = []

    // MARK: Initialization
    
    public init(_ tool: Tool) {
        self.tool = tool
        
        super.init(frame: .zero)
        
        buildViewHieararchy()
        setupConstraints()
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Functions
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(rect)
        
        strokes.forEach { stroke in
            context.setLineWidth(stroke.width)
            context.setStrokeColor(stroke.color)
            context.setLineCap(.round)
            drawBeziérStroke(stroke, in: context)
        }
    }
    
    // MARK: Private Functions
    
    private func buildViewHieararchy() {
        
    }
    
    private func setupConstraints() {
        
    }
    
    private func configureViews() {
        backgroundColor = UIColor.clear
        addGestureRecognizer(strokeGestureRecognizer)
    }
    
    private func drawBeziérStroke(_ stroke: Stroke, in context: CGContext) {
        let samples = stroke.samples
        let samplesCount = stroke.samples.count
        
        var reamingSamples = 0
        var quadCurves = 0
        
        if samplesCount >= 4 {
            reamingSamples = (samplesCount - 4) % 3
            quadCurves = 1 + ((samplesCount - 4) - reamingSamples) / 3
        } else {
            reamingSamples = samplesCount
        }
        
        let bezierPath = UIBezierPath()
        
        var lastUsedStrokeSampleIndex = 0
        
        if samplesCount > 0 {
            bezierPath.move(to: samples[lastUsedStrokeSampleIndex].location)
        }
        
        while quadCurves > 0 {
            let controlPoint1 = samples[lastUsedStrokeSampleIndex + 1].location
            let controlPoint2 = samples[lastUsedStrokeSampleIndex + 2].location
            var endPoint: CGPoint
            
            if quadCurves > 1 {
                let nextControlPoint1 = samples[lastUsedStrokeSampleIndex + 4].location
                
                endPoint = CGPoint(x: (controlPoint2.x + nextControlPoint1.x) / 2.0,
                                   y: (controlPoint2.y + nextControlPoint1.y) / 2.0)
            } else {
                endPoint = samples[lastUsedStrokeSampleIndex + 3].location
            }
            
            bezierPath.addCurve(to: endPoint,
                                controlPoint1: controlPoint1,
                                controlPoint2: controlPoint2)
            
            quadCurves -= 1
            lastUsedStrokeSampleIndex += 3
        }
        
        while reamingSamples > 0 {
            bezierPath.addLine(to: samples[lastUsedStrokeSampleIndex].location)
            reamingSamples -= 1
            lastUsedStrokeSampleIndex += 1
        }
        
        context.addPath(bezierPath.cgPath)
        context.strokePath()
    }
    
    private func drawRegularStroke(_ stroke: Stroke, in context: CGContext) {
        context.move(to: stroke.samples[0].location)
        for strokeSample in stroke.samples[1...] {
            context.addLine(to: strokeSample.location)
        }
        context.strokePath()
    }
    
    private func refreshCanvas() {
        setNeedsDisplay()
    }
    
    // MARK: Public Functions
    
    public func clearCanvas() {
        strokes = []
        refreshCanvas()
    }
    
    public func getDrawingImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(bounds)
        
        strokes.forEach { stroke in
            context.setLineWidth(stroke.width)
            context.setStrokeColor(stroke.color)
            context.setLineCap(.round)
            drawBeziérStroke(stroke, in: context)
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

// MARK: - : StrokeGestureRecognizerDelegate

extension CanvasView: StrokeGestureRecognizerDelegate {
    func touchPossible() {
        guard let newStroke = strokeGestureRecognizer.stroke else { return }
        newStroke.width = tool.width!
        newStroke.color = tool.color!
        strokes.append(newStroke)
        refreshCanvas()
    }

    func touchMoved() {
        refreshCanvas()
    }

    func touchFailed() {
        strokes.removeLast()
        refreshCanvas()
    }
}
