import UIKit

class SavedColorsCollectionViewCell: UICollectionViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.width / 2
    }
}
