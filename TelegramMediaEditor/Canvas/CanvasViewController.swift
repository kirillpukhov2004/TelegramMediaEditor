import UIKit
import Photos

// MARK: - AssetSavingType

enum CanvasViewControllerTransitionType {
    case save
    case saveAs
    case cancel
}

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
    private(set) lazy var toolBarView: CanvasToolBarView = {
        let toolBarView = CanvasToolBarView()
        toolBarView.delegate = self
        toolBarView.translatesAutoresizingMaskIntoConstraints = false
        
        return toolBarView
    }()
    
    private(set) lazy var scrollView: UIScrollView = {
        let scrollView =  UIScrollView()
        scrollView.delegate = self
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = false
        return scrollView
    }()
    private(set) lazy var canvasWrapperView: UIView = {
        let view = UIView()
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        return view
    }()
    private(set) lazy var canvasView: CanvasView = {
        let canvasView = CanvasView(toolBarView.activeTool)
        canvasView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        return canvasView
    }()
    private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        return imageView
    }()

    private(set) lazy var topBarStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        
        return stackView
    }()
    private(set) lazy var resetZoomScaleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Zoom Out", for: .normal)
        button.setImage(UIImage(named: "zoomOut")!, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.setTitleColor(.secondaryLabel, for: .highlighted)
        button.addTarget(self, action: #selector(resetZoomScaleButtonPressed), for: .touchDown)
        
        return button
    }()
    private(set) lazy var clearAllButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Clear All", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.setTitleColor(.secondaryLabel, for: .highlighted)
        button.addTarget(self, action: #selector(clearAllButtonPressed), for: .touchDown)
        
        return button
    }()
    private(set) lazy var undoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "undo")!, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.addTarget(self, action: #selector(undoButtonPressed), for: .touchDown)
        
        return button
    }()
    
    public var imageAsset: PHAsset!
    public var image: UIImage! {
        didSet {
            imageView.image = image
        }
    }
    
    public var drawingRect: CGRect {
        // Calculating actual image frame inside imageView accroding to content mode .scaleAspectFit
        let widthRatio = imageView.bounds.size.width / image.size.width
        let heightRatio = imageView.bounds.size.height / image.size.height
        let scale = min(widthRatio, heightRatio)
        
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let origin = CGPoint(x: imageView.bounds.width / 2 - size.width / 2, y: imageView.bounds.height / 2 - size.height / 2)
        
        return CGRect(origin: origin, size: size)
    }
    
    public var transitionType: CanvasViewControllerTransitionType?
    
    // MARK: Lifecycle
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        
        buildViewHierarchy()
        setupLayout()
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
        canvasWrapperView.addSubview(imageView)
        canvasWrapperView.addSubview(canvasView)
        
        view.addSubview(topBarStackView)
        topBarStackView.addArrangedSubview(undoButton)
        topBarStackView.addArrangedSubview(resetZoomScaleButton)
        topBarStackView.addArrangedSubview(clearAllButton)
        
        view.addSubview(toolBarView)
    }
    
    private func setupLayout() {
        canvasWrapperView.frame = scrollView.bounds
        imageView.frame = canvasWrapperView.bounds
        
        topBarStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topBarStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            topBarStackView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            topBarStackView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            topBarStackView.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topBarStackView.bottomAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants.canvasEdgeInsets.bottom),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: canvasWrapperView.topAnchor),
            imageView.rightAnchor.constraint(equalTo: canvasWrapperView.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: canvasWrapperView.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: canvasWrapperView.leftAnchor)
        ])
        
        NSLayoutConstraint.activate([
            toolBarView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
            toolBarView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -8),
            toolBarView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            toolBarView.heightAnchor.constraint(equalToConstant: 82),
        ])
    }
    
    private func configureViews() {
        overrideUserInterfaceStyle = .dark
        
        resetZoomScaleButton.isHidden = true
        
        imageView.image = image
    }
    
    public func generateImage() -> UIImage {
        let drawing = canvasView.getDrawingImage()
        
        let rect = CGRect(origin: .zero, size: image.size)
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 1)
        image.draw(in: rect)
        drawing?.draw(in: rect, blendMode: .normal, alpha: 1.0)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }
}

// MARK: - : UIScrollViewDelegate

extension CanvasViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvasWrapperView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        resetZoomScaleButton.isHidden = (scrollView.zoomScale <= 1)
    }
}

// MARK: - : ToolBarViewDelegate

extension CanvasViewController: CanvasToolBarViewDelegate {
    func canvasToolBarViewActiveToolChanged(_ canvasToolBarView: CanvasToolBarView) {
        let newActiveTool = canvasToolBarView.activeTool
        canvasView.tool = newActiveTool
    }
    
    func canvasToolBarCancelButtonPressed(_ canvasToolBarView: CanvasToolBarView) {
        scrollView.setZoomScale(1, animated: true)
        
        transitionType = .cancel
        navigationController?.popViewController(animated: true)
    }
    
    func canvasToolBarSaveButtonPressed(_ canvasToolBarView: CanvasToolBarView) {
        scrollView.setZoomScale(1, animated: true)
        
        let image = generateImage()
        PHPhotoLibrary.shared().performChanges({
            _ = PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { [weak self] success, error in
            if let error = error {
                print("🔴 \(#function): \(error)")
            }
            
            if success {
                self?.transitionType = .saveAs
                DispatchQueue.main.async {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
