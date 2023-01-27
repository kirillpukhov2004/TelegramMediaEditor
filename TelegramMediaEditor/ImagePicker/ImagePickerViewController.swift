import UIKit
import Photos

// MARK: - UIViewController

class ImagePickerViewController: UIViewController {
    var collectionView: UICollectionView!
    
    var autorizationStatus: PHAuthorizationStatus!
    var photosAssets: PHFetchResult<PHAsset>!
    var activityIndicator: UIActivityIndicatorView!
    
    var imagesPerRow: Int = 5
    var maximumImagesPerRow: Int {
        return Int(view.bounds.width / CGFloat(10))
    }
    var imagePadding: CGFloat {
        return CGFloat(imagesPerRow <= 5 ? 2 : 0)
    }
    
    func configureViews() {
        // Configuring ViewController
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Configuring CollectionView
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
        collectionView.register(ImagePickerCollectionViewCell.self, forCellWithReuseIdentifier: ImagePickerCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        
        // Configuraing ActivityIndicator
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        activityIndicator.color = .white
        activityIndicator.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.2)
        activityIndicator.stopAnimating()
        
        // Adding Subviews
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
    }
    
    func setupConstraints() {
        // Constraining CollectionView
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
        
        // Constraining ActivityIndicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.topAnchor.constraint(equalTo: view.topAnchor),
            activityIndicator.rightAnchor.constraint(equalTo: view.rightAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicator.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
    }
    
    override func loadView() {
        super.loadView()
        
        configureViews()
        setupConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        autorizationStatus = PHPhotoLibrary.authorizationStatus()
        if autorizationStatus == .authorized {
            let fetchOptions = PHFetchOptions()
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            fetchOptions.sortDescriptors = [sortDescriptor]
            photosAssets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            collectionView.reloadData()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}


// MARK: - UICollectionViewDataSource

extension ImagePickerViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if autorizationStatus == .authorized {
            return photosAssets.count
        } else {
            return 0
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImagePickerCollectionViewCell.identifier,
            for: indexPath
        ) as! ImagePickerCollectionViewCell
        
        //        let section = indexPath.section
        guard let photosAssets = photosAssets else { return  UICollectionViewCell() }
        let asset = photosAssets[indexPath.row]
        cell.setup(with: asset)
        
        return cell
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension ImagePickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImagePickerCollectionViewCell else {
            print("🔴 \(#function): Can't get cell for item at \(indexPath)"); return
        }
        
        guard let photoAsset = cell.asset else {
            print("🔴 \(#function): Can't get photoAsset for cell"); return
        }
        
        let canvasViewController = CanvasViewController()
        
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
                        self?.navigationController?.pushViewController(canvasViewController,
                                                                       animated: true)
                    }
                }
            }
        }
        
        _ = PHImageManager.default().requestImageDataAndOrientation(
            for: photoAsset,
            options: imageReqeustOptions
        ) { imageData, _, _, _ in
//            guard let imageData = imageData else {
//                print("🔴 \(#function): Image data is nil"); return
//            }
//
//            canvasViewController.image = UIImage(data: imageData)
//            canvasViewController.asset = photoAsset
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let totalPadding: CGFloat = CGFloat(imagesPerRow - 1) * imagePadding
        let size = (collectionView.bounds.width - totalPadding) / CGFloat(imagesPerRow)
        return CGSize(width: size, height: size)
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
}
