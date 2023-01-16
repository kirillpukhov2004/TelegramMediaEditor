import UIKit
import Photos

class ImagePickerCollectionViewCell: UICollectionViewCell {
    public static let identifier = "PhotosCollectionViewCell"
    
    private var imageView: UIImageView
    
    private(set) var asset: PHAsset!
    
    private var imageRequestID: PHImageRequestID?

    public func setup(with asset: PHAsset) {
        self.asset = asset
        
        imageRequestID = PHImageManager.default().requestImage(for: asset,
                                              targetSize: bounds.size,
                                              contentMode: .aspectFill,
                                              options: nil) { image, info in
            self.imageView.image = image
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    
        imageView.image = nil
        asset = nil
        if let imageRequestID = imageRequestID {
            PHImageManager.default().cancelImageRequest(imageRequestID)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = contentView.bounds
    }
    
    override init(frame: CGRect) {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
