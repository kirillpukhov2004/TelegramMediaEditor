import UIKit
import Photos

// MARK: - Constants

fileprivate struct Constants {
    static let canvasEdgeInsets: UIEdgeInsets = {
        var edgeInsets = UIEdgeInsets()
        edgeInsets.top = 44
        edgeInsets.bottom = -98
        return edgeInsets
    }()
}

// MARK: - CanvasViewController

class CanvasViewController: UIViewController {
    private lazy var toolBarView: CanvasToolBarView = {
        let toolBarView = CanvasToolBarView()
        toolBarView.delegate = self
        toolBarView.translatesAutoresizingMaskIntoConstraints = false
        return toolBarView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView =  UIScrollView()
        scrollView.delegate = self
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    private lazy var canvasWrapperView: UIView = {
        let view = UIView()
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        return view
    }()
    private lazy var canvasView: CanvasView = {
        let canvasView = CanvasView(toolBarView.activeTool)
        canvasView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        return canvasView
    }()
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        return imageView
    }()
    
    private lazy var resetZoomScaleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Zoom Out", for: .normal)
        button.setImage(UIImage(named: "zoomOut")!, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.setTitleColor(.secondaryLabel, for: .highlighted)
        button.addTarget(self, action: #selector(resetZoomScaleButtonPressed), for: .touchDown)
        return button
    }()
    private lazy var clearAllButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Clear All", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.setTitleColor(.secondaryLabel, for: .highlighted)
        button.addTarget(self, action: #selector(clearAllButtonPressed), for: .touchDown)
        
        return button
    }()
    public lazy var undoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "undo")!, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.addTarget(self, action: #selector(undoButtonPressed), for: .touchDown)
        return button
    }()
    
    public var backgroundImage: UIImage? {
        get {
            return backgroundImageView.image
        }
        
        set {
            backgroundImageView.image = newValue
            canvasView.frame = drawingRect
        }
    }
    public var backgroundImageAsset: PHAsset?
    
    private var drawingRect: CGRect {
        guard let backgroundImage = backgroundImage else { return backgroundImageView.bounds }
        
        // Calculating actual image frame inside imageView accroding to content mode .scaleAspectFit
        let widthRatio = backgroundImageView.bounds.size.width / backgroundImage.size.width
        let heightRatio = backgroundImageView.bounds.size.height / backgroundImage.size.height
        let scale = min(widthRatio, heightRatio)
        
        let size = CGSize(width: backgroundImage.size.width * scale, height: backgroundImage.size.height * scale)
        let origin = CGPoint(x: backgroundImageView.bounds.width / 2 - size.width / 2, y: backgroundImageView.bounds.height / 2 - size.height / 2)
        
        return CGRect(origin: origin, size: size)
    }
    
    // MARK: Initialization
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        canvasView.frame = drawingRect
    }
    
    // MARK: Actions
    
    @objc private func resetZoomScaleButtonPressed() {
        scrollView.setZoomScale(1, animated: true)
    }
    
    @objc private func clearAllButtonPressed() {
        canvasView.clearCanvas()
    }
    
    @objc private func undoButtonPressed() {
        print(#function)
    }
    
    // MARK: Private Funcitons
    
    private func buildViewHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(canvasWrapperView)
        canvasWrapperView.addSubview(backgroundImageView)
        canvasWrapperView.addSubview(canvasView)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: undoButton)
        navigationItem.titleView = resetZoomScaleButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: clearAllButton)
        
        view.addSubview(toolBarView)
    }
    
    private func setupConstraints() {
        canvasWrapperView.frame = scrollView.bounds
        backgroundImageView.frame = canvasWrapperView.bounds
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants.canvasEdgeInsets.bottom),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: canvasWrapperView.topAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: canvasWrapperView.rightAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: canvasWrapperView.bottomAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: canvasWrapperView.leftAnchor)
        ])
        
        NSLayoutConstraint.activate([
            toolBarView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            toolBarView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -8),
            toolBarView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            toolBarView.heightAnchor.constraint(equalToConstant: 82),
        ])
    }
    
    private func configureViews() {
        overrideUserInterfaceStyle = .dark
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        navigationItem.titleView?.isHidden = true
        navigationController?.navigationBar.isTranslucent = false
    }
    
    private func generateImage() -> UIImage {
        let drawing = canvasView.getDrawingImage()
        let image = backgroundImage
        
        UIGraphicsBeginImageContextWithOptions(image!.size, true, 0)
        
        let rect = CGRect(origin: .zero, size: image!.size)
        
        image?.draw(in: rect)
        drawing?.draw(in: rect, blendMode: .normal, alpha: 1)
        
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}

// MARK: - : UIScrollViewDelegate

extension CanvasViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvasWrapperView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        navigationItem.titleView?.isHidden = (scrollView.zoomScale <= 1)
    }
}

// MARK: - : ToolBarViewDelegate

extension CanvasViewController: CanvasToolBarViewDelegate {
    func canvasToolBarViewActiveToolChanged(_ canvasToolBarView: CanvasToolBarView) {
        let newActiveTool = canvasToolBarView.activeTool
        canvasView.tool = newActiveTool
    }
    
    func canvasToolBarCancelButtonPressed(_ canvasToolBarView: CanvasToolBarView) {
        navigationController?.popViewController(animated: true)
    }
    
    func canvasToolBarSaveButtonPressed(_ canvasToolBarView: CanvasToolBarView) {
        let image = generateImage()
        PHPhotoLibrary.shared().performChanges({
            _ = PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { [weak self] success, error in
            if let error = error {
                print(#function, error)
            }
            
            if success {
                DispatchQueue.main.async {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
