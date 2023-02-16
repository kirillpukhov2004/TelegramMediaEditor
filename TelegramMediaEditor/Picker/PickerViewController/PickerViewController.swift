import UIKit
import Photos

// MARK: - PickerViewController

class PickerViewController: UIViewController {
    lazy var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PickerCollectionViewPhotoCell.self, forCellWithReuseIdentifier: PickerCollectionViewPhotoCell.identifier)
        
        return collectionView
    }()
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        activityIndicator.color = .white
        activityIndicator.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.2)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = true
        
        return activityIndicator
    }()
    
    private var autorizationStatus: PHAuthorizationStatus {
        PHPhotoLibrary.authorizationStatus()
    }
    private var assets: PHFetchResult<PHAsset>?
    
    var imagesPerRow: Int = 5
    var maximumImagesPerRow: Int {
        return Int(view.bounds.width / CGFloat(10))
    }
    var imagePadding: CGFloat {
        return CGFloat(imagesPerRow <= 5 ? 2 : 0)
    }
    
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
        view.addSubview(activityIndicator)
    }
    
    private func configureViews() {
        overrideUserInterfaceStyle = .dark
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.topAnchor.constraint(equalTo: view.topAnchor),
            activityIndicator.rightAnchor.constraint(equalTo: view.rightAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicator.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
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
            print("🔴 \(#function): Can't get photoAsset for cell"); return
        }
        
        activityIndicator.style = .large
        activityIndicator.frame = view.frame
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        let imageReqeustOptions = PHImageRequestOptions()
        imageReqeustOptions.isNetworkAccessAllowed = true
        imageReqeustOptions.progressHandler = { [weak self] (progress, error, _, _) in
            DispatchQueue.main.async {
                if progress == 1.0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self?.activityIndicator.stopAnimating()
                    }
                }
            }
        }
        
        _ = PHImageManager.default().requestImageDataAndOrientation(
            for: photoAsset,
            options: imageReqeustOptions
        ) { [weak self] imageData, _, _, _ in
            guard let imageData = imageData else {
                print("🔴 \(#function): Image data is nil"); return
            }

            guard let image = UIImage(data: imageData) else { fatalError() }
            let canvasViewController = CanvasViewController()
            canvasViewController.backgroundImage = image
            canvasViewController.backgroundImageAsset = photoAsset
            self?.navigationController?.pushViewController(canvasViewController, animated: true)
        }
    }
}
