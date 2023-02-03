import UIKit

protocol ColorSelectionView: UIView {
    var delegate: ColorSelectionViewDelegate? { get set }
    
    var selectedColor: CGColor? { get }
    
    func setColor(to color: CGColor)
    
    func colorChanged(to color: CGColor)
}

extension ColorSelectionView {
    func colorChanged(to color: CGColor) {}
}
