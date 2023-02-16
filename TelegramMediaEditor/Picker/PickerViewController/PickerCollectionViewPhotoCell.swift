import UIKit
import Photos

// MARK: - PickerCollectionViewPhotoCell

class PickerCollectionViewPhotoCell: UICollectionViewCell {
    private typealias ImageRequestResultHandler = (UIImage?, [AnyHashable : Any]?) -> Void
    
    public static let identifier = "PickerCollectionViewPhotoCell"
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: bounds)
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private(set) var asset: PHAsset?
    public var imageCnotentMode: PHImageContentMode? {
        didSet {
            switch imageCnotentMode {
            case .aspectFit:
                imageView.contentMode = .scaleAspectFit
                fetchImage { [weak self] image, _ in
                    self?.imageView.image = image
                }
            default:
                imageView.contentMode = .scaleAspectFill
                fetchImage { [weak self] image, _ in
                    self?.imageView.image = image
                }
            }
        }
    }
    
    private var imageRequestID: PHImageRequestID?
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
    
        if let imageRequestID = imageRequestID {
            PHImageManager.default().cancelImageRequest(imageRequestID)
        }
        imageView.image = nil
        
        asset = nil
        imageCnotentMode = nil
    }

    // MARK: Private Functions
    
    private func fetchImage(_ resultHandler: @escaping ImageRequestResultHandler) {
        guard let asset = asset,
              let imageCnotentMode = imageCnotentMode else { return }
        
        imageRequestID = PHImageManager.default().requestImage(
            for: asset,
            targetSize: imageView.bounds.size,
            contentMode: imageCnotentMode,
            options: nil,
            resultHandler: resultHandler
        )
    }
    
    // MARK: Public Functions
    
    public func configure(asset: PHAsset, imageContentMode: PHImageContentMode) {
        self.asset = asset
        self.imageCnotentMode = imageContentMode
        
        fetchImage { [weak self] image, _ in
            self?.imageView.image = image
        }
    }
}
