import UIKit

// MARK: - SpectrumColorSelectionView

class SpectrumColorSelectionView: UIView, ColorSelectionView {
    public weak var delegate: ColorSelectionViewDelegate?
    
    var selectedColor: CGColor?
    
    // MARK: Initialization
    
    public init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public Functions
    
    public func setColor(to color: CGColor) {
        return
    }
}
