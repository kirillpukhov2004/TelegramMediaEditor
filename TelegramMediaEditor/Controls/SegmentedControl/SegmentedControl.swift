import UIKit

class SegmentedControl: UIControl {
    private(set) var segments: [String]
    private(set) var selectedSegmentIndex: Int?
    private var segmentLabels: [UILabel]
    
    private var selectedSegmentIndicator: CALayer!
    
    init() {
        segments = [String]()
        segmentLabels = [UILabel]()
        selectedSegmentIndicator = CALayer()
        selectedSegmentIndicator.backgroundColor = CGColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3)
        selectedSegmentIndicator.masksToBounds = true
        
        super.init(frame: .zero)
        
        backgroundColor = UIColor(cgColor: CGColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1))
        layer.masksToBounds = true
        layer.insertSublayer(selectedSegmentIndicator, at: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setSegments(_ segments: [String]) {
        self.segments = segments
        
        segmentLabels = []
        segments.enumerated().forEach { (index, segment) in
            let label = UILabel()
            label.text = segment
            label.font = .systemFont(ofSize: 14, weight: .semibold)
            label.textColor = .white
            label.textAlignment = .center
            label.layer.masksToBounds = true
            addSubview(label)
            segmentLabels.append(label)
        }
        
        if selectedSegmentIndex == nil && !segments.isEmpty || selectedSegmentIndex == nil {
            selectedSegmentIndex = 0
            selectSegment(segmentLabels[0], animated: false)
        } else if segments.isEmpty {
            selectedSegmentIndex = nil
        }
    }
    
    public func selectSegment(_ segment: UILabel, animated: Bool = true) {
        guard let selectedSegmentIndex = selectedSegmentIndex else { return }
        guard let newSelectedSegmentIndex = segmentLabels.enumerated().first(where: { $0.element == segment })?.offset else { return }
        let selectedSegment = segmentLabels[selectedSegmentIndex]
        
        if animated {
            let segmentWidth = (frame.width - 5.0) / CGFloat(segmentLabels.count)
            let deltaPosition = segmentWidth * CGFloat(newSelectedSegmentIndex - selectedSegmentIndex)
            
            let animation = CABasicAnimation(keyPath: "position.x")
            animation.duration = 0.25
            animation.fromValue = selectedSegment.layer.position.x
            animation.toValue = selectedSegment.layer.position.x + deltaPosition
            animation.fillMode = .both
            animation.isRemovedOnCompletion = false
            selectedSegmentIndicator.add(animation, forKey: nil)
            
            self.selectedSegmentIndex = newSelectedSegmentIndex
        } else {
            selectedSegmentIndicator.frame = segmentLabels[newSelectedSegmentIndex].frame
            self.selectedSegmentIndex = newSelectedSegmentIndex
        }
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchLocation = touch.location(in: self)
        
        if let selectedSegment = segmentLabels.enumerated().first(where: { $0.element.frame.contains(touchLocation) }) {
            selectSegment(selectedSegment.element)
        }
        
        return false
    }
    
    override func layoutSubviews() {
        let labelWidth = (frame.width - 5.0) / CGFloat(segmentLabels.count)
        segmentLabels.enumerated().forEach { (index, segmentLabel) in
            segmentLabel.frame = CGRect(x: 2.5 + labelWidth * CGFloat(index),
                                 y: 2.5,
                                 width: (frame.width - 5.0) / CGFloat(segmentLabels.count),
                                 height: frame.height - 5.0)
            segmentLabel.layer.cornerRadius = segmentLabel.frame.height / 2.0
        }
        
        layer.cornerRadius = frame.height / 2
        if let selectedSegmentIndex = selectedSegmentIndex {
            selectedSegmentIndicator.frame = segmentLabels[selectedSegmentIndex].frame
            selectedSegmentIndicator.cornerRadius = selectedSegmentIndicator.frame.height / 2
        }
    }
}
