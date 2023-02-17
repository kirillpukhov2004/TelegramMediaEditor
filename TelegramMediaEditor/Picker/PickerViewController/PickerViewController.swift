import UIKit
import Photos

// MARK: - PickerViewController

class PickerViewController: UIViewController {
    fileprivate typealias CollectionViewDataSource = UICollectionViewDiffableDataSource<Int, PHAsset>
    
    private(set) lazy var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.register(PickerCollectionViewPhotoCell.self, forCellWithReuseIdentifier: PickerCollectionViewPhotoCell.identifier)
        
        return collectionView
    }()
    private var collectionViewDiffableDataSource: CollectionViewDataSource!
    
    private var autorizationStatus: PHAuthorizationStatus {
        PHPhotoLibrary.authorizationStatus()
    }
    private(set) var assets: PHFetchResult<PHAsset>?
    
    private var notificationObserver: NSObjectProtocol!
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
        
        updateSnapshot()
    }
    
    // MARK: Private Functions
    
    private func buildViewHierarchy() {
        view.addSubview(collectionView)
    }
    
    private func configureViews() {
        overrideUserInterfaceStyle = .dark
        navigationController?.delegate = self
        
        notificationObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.updateSnapshot()
        }

        
        collectionViewDiffableDataSource = CollectionViewDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, asset in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PickerCollectionViewPhotoCell.identifier,
                for: indexPath
            ) as! PickerCollectionViewPhotoCell
            
            cell.configure(asset: asset, imageContentMode: .aspectFill)
            
            return cell
        })
        
        updateSnapshot()
    }
    
    private func setupConstraints() {
    }
    
    private func updateSnapshot() {
        fetchAssets()
        var snapshot = NSDiffableDataSourceSnapshot<Int, PHAsset>()
        snapshot.appendSections([0])
        if let assets = assets {
            snapshot.appendItems(assets.objects(at: IndexSet(0..<assets.count)))
        }
        collectionViewDiffableDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func fetchAssets() {
        switch autorizationStatus {
        case .authorized:
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [sortDescriptor]
            
            assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        default:
            assets = nil
        }
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

// MARK: - UINavigationControllerDelegate

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
