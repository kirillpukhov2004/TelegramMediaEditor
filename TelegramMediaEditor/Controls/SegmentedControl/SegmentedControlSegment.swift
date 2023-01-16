import UIKit

class SegmentedControlSegment: UIView {
    public var label: UILabel
    
    init() {
        label = UILabel()
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
