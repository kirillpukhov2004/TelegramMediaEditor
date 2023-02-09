import UIKit

enum SegmentedControlCorners {
    case circle
    case rounded
    case squared
}

// MARK: - SegmentedControl

class SegmentedControl: UIControl {
    private(set) var segments = [String]()
    private(set) var selectedSegmentIndex: Int?
    private var labels = [UILabel]()
    
    private lazy var selectedSegmentBackgroundLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor.copy(alpha: 0.3)!
        return layer
    }()
    
    var segmentedControlCorners: SegmentedControlCorners = .rounded {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: Initialization
    
    public init() {
        super.init(frame: .zero)
        
        buildViewHierarchy()
        setupConstraints()
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func layoutSubviews() {
        let labelWidth = bounds.width / labels.count
        
        labels.enumerated().forEach { index, segmentLabel in
            segmentLabel.frame = CGRect(
                x: labelWidth * index,
                y: 0,
                width: labelWidth,
                height: bounds.height
            )
        }
        
        if let selectedSegmentIndex = selectedSegmentIndex {
            let label = labels[selectedSegmentIndex]
            updateSelectedSegmentBackgroudLayer(label.frame)
            setCorners(forLayer: selectedSegmentBackgroundLayer)
        }
        
        setCorners(forLayer: layer)
    }
    
    // MARK: Touches Handling
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchLocation = touch.location(in: self)
        
        if let selectedSegment = labels.enumerated().first(where: { $0.element.frame.contains(touchLocation) }) {
            selectSegment(selectedSegment.element)
        }
        
        return false
    }
    
    // MARK: Private Functions
    
    private func buildViewHierarchy() {
        layer.addSublayer(selectedSegmentBackgroundLayer)
    }
    
    private func setupConstraints() {
        
    }
    
    private func configureViews() {
        layer.backgroundColor = UIColor.white.cgColor.copy(alpha: 0.1)!
        layer.masksToBounds = true
    }
    
    private func setCorners(forLayer layer: CALayer) {
        switch segmentedControlCorners {
        case .rounded:
            layer.cornerRadius = min(layer.bounds.height, layer.bounds.width) / 3
        case .circle:
            layer.cornerRadius = min(layer.bounds.height, layer.bounds.width) / 2
        case .squared:
            layer.cornerRadius = 0
        }
    }
    
    private func updateSelectedSegmentBackgroudLayer(_ frame: CGRect, insets: CGFloat = 2.5) {
        let insets = UIEdgeInsets(top: insets, left: insets, bottom: insets, right: insets)
        selectedSegmentBackgroundLayer.frame = frame
        selectedSegmentBackgroundLayer.bounds = frame.inset(by: insets)
    }
    
    // MARK: Public Functions
    
    public func setSegments(_ segments: [String]) {
        self.segments = segments
        
        labels = []
        segments.enumerated().forEach { (index, segment) in
            let label = UILabel()
            label.text = segment
            label.font = .systemFont(ofSize: 13, weight: .semibold)
            label.textColor = .white
            label.textAlignment = .center
            label.layer.masksToBounds = true
            addSubview(label)
            labels.append(label)
        }
        
        if !segments.isEmpty && selectedSegmentIndex == nil {
            selectSegment(labels[0])
        } else if segments.isEmpty {
            selectedSegmentIndex = nil
            selectedSegmentBackgroundLayer.removeFromSuperlayer()
        }
    }
    
    public func selectSegment(_ segment: UILabel) {
        guard let newSelectedSegmentIndex = labels.enumerated().first(where: { $0.element == segment })?.offset else { return }
        let newSelectedSegment = labels[newSelectedSegmentIndex]
        
        updateSelectedSegmentBackgroudLayer(newSelectedSegment.frame)
        setCorners(forLayer: selectedSegmentBackgroundLayer)
        
        if let selectedSegmentIndex = selectedSegmentIndex {
            let selectedSegment = labels[selectedSegmentIndex]
            
            let slideAnimation = CABasicAnimation(keyPath: "frame.origin.x")
            slideAnimation.duration = 0.25
            slideAnimation.fromValue = selectedSegment.frame.origin.x
            slideAnimation.toValue = newSelectedSegment.frame.origin.x
            
            selectedSegmentBackgroundLayer.add(slideAnimation, forKey: nil)
        }
        
        selectedSegmentIndex = newSelectedSegmentIndex
        sendActions(for: .valueChanged)
    }
}
