import UIKit

class CanvasView: UIView {
    private(set) var tool: Tool
    private(set) var strokes: [Stroke] = []
    
    private lazy var strokeGestureRecognizer: StrokeGestureRecognizer = {
        let gestureRecognizer = StrokeGestureRecognizer()
        gestureRecognizer.strokeDelegate = self
        return gestureRecognizer
    }()
    
    public init(_ tool: Tool) {
        self.tool = tool
        
        super.init(frame: .zero)
        
        buildViewHieararchy()
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildViewHieararchy() {
        
    }
    
    private func configureViews() {
        backgroundColor = .clear
        addGestureRecognizer(strokeGestureRecognizer)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        strokes.forEach { stroke in
            context.setLineWidth(stroke.width)
            context.setStrokeColor(stroke.color)
            context.setLineCap(.round)
            drawStroke(stroke, in: context)
        }
    }
    
    private func drawStroke(_ stroke: Stroke, in context: CGContext) {
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
    
    private func refreshCanvas() {
        setNeedsDisplay()
    }
}

extension CanvasView: StrokeGestureRecognizerDelegate {
    func touchPossible() {
        guard let newStroke = strokeGestureRecognizer.stroke else { return }
        newStroke.width = tool.width
        newStroke.color = tool.color
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
