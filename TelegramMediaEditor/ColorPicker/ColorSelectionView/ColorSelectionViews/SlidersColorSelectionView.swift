import UIKit

class SlidersColorSelectionView: UIView, ColorSelectionView {
    public weak var delegate: ColorSelectionViewDelegate?
    
    var selectedColor: CGColor?
    
    func setColor(to color: CGColor) {
        return
    }
}
