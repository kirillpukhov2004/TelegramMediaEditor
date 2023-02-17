import UIKit
import Photos

// MARK: - PickerViewController

class PickerViewController: UIViewController {
    private(set) lazy var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PickerCollectionViewPhotoCell.self, forCellWithReuseIdentifier: PickerCollectionViewPhotoCell.identifier)
        
        return collectionView
    }()
    
    private var autorizationStatus: PHAuthorizationStatus {
        PHPhotoLibrary.authorizationStatus()
    }
    private(set) var assets: PHFetchResult<PHAsset>?

    var imagesPerRow: Int = 5
    var maximumImagesPerRow: Int {
        return Int(view.bounds.width / 10)
    }
    var imagePadding: CGFloat {
        return CGFloat(imagesPerRow <= 5 ? 2 : 0)
    }
    
    var selectedCellIndexPath: IndexPath?
    
    // MARK: Lifecycle
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        
        buildViewHierarchy()
        setupConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchAssets()
        collectionView.reloadData()
    }
    
    // MARK: Private Functions
    
    private func buildViewHierarchy() {
        view.addSubview(collectionView)
    }
    
    private func configureViews() {
        overrideUserInterfaceStyle = .dark
        navigationController?.delegate = self
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupConstraints() {
    }
    
    private func fetchAssets() {
        switch autorizationStatus {
        case .authorized:
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [sortDescriptor]
            
            assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        default:
            break
        }
    }
}

// MARK: - UICollectionViewDataSource

extension PickerViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard let assets = assets else { return 0 }
        
        switch autorizationStatus {
        case .authorized:
            return assets.count
        default:
            return 0
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PickerCollectionViewPhotoCell.identifier,
            for: indexPath
        ) as! PickerCollectionViewPhotoCell
        
        guard let asset = assets?[indexPath.row] else {
            print("🔴 \(#function): Can't get asset for indexPath: \(indexPath)"); return cell
        }
        
        cell.configure(asset: asset, imageContentMode: .aspectFill)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return imagePadding
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return imagePadding
    }
        
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0  , left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let totalPadding: CGFloat = (imagesPerRow - 1) * imagePadding
        let size = (collectionView.bounds.width - totalPadding) / imagesPerRow
        return CGSize(width: size, height: size)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PickerCollectionViewPhotoCell else {
            print("🔴 \(#function): Can't get cell for item at \(indexPath)"); return
        }
        
        guard let photoAsset = cell.asset else {
            print("🔴 \(#function): Can't get asset for cell at indexPath: \(indexPath)"); return
        }
        
        let imageReqeustOptions = PHImageRequestOptions()
        imageReqeustOptions.version = .current
        imageReqeustOptions.isSynchronous = true
        imageReqeustOptions.isNetworkAccessAllowed = true
        
        _ = PHImageManager.default().requestImageDataAndOrientation(
            for: photoAsset,
            options: imageReqeustOptions
        ) { [weak self] data, _, _, _ in
            guard let data = data else {
                print("🔴 \(#function): Image data is nil"); return
            }
            
            guard let image = UIImage(data: data) else {
                print("🔴 \(#function): Can't create image from imageData"); return
            }
            
            let canvasViewController = CanvasViewController(backgroundImageAsset: photoAsset, backgroundImage: image)
            
            self?.navigationController?.pushViewController(canvasViewController, animated: true)
        }
        
        selectedCellIndexPath = indexPath
    }
}


extension PickerViewController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return TransitionAnimationContorller()
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
}
