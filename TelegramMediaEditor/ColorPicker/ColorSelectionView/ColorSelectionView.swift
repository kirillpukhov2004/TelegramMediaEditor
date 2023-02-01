import UIKit

protocol ColorSelectionView: UIView {
    var delegate: ColorSelectionViewDelegate? { get set }
    
    var selectedColor: CGColor? { get }
    
    func setColor(to color: CGColor)
}
