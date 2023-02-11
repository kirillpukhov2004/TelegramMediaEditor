import UIKit

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
    lazy var scrollView: UIScrollView = {
        let scrollView =  UIScrollView()
        scrollView.delegate = self
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
//        scrollView.clipsToBounds = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    lazy var canvasView: CanvasView = {
        let canvasView = CanvasView(toolBarView.activeTool)
        return canvasView
    }()
    
    lazy var topBarView: CanvasTopBarView = {
        let topBarView = CanvasTopBarView()
        topBarView.delegate = self
        topBarView.translatesAutoresizingMaskIntoConstraints = false
        return topBarView
    }()
    lazy var toolBarView: CanvasToolBarView = {
        let toolBarView = CanvasToolBarView()
        toolBarView.delegate = self
        toolBarView.translatesAutoresizingMaskIntoConstraints = false
        return toolBarView
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildViewHierarchy()
        setupConstraints()
        configureViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        canvasView.frame = scrollView.bounds
    }
    
    func buildViewHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(canvasView)
        view.addSubview(topBarView)
        view.addSubview(toolBarView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: Constants.canvasEdgeInsets.top),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants.canvasEdgeInsets.bottom),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])

//        NSLayoutConstraint.activate([
//            canvasView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            canvasView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
//            canvasView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            canvasView.leftAnchor.constraint(equalTo: scrollView.leftAnchor)
//        ])
//
        NSLayoutConstraint.activate([
            topBarView.topAnchor.constraint(equalTo: view.topAnchor),
            topBarView.rightAnchor.constraint(equalTo: view.rightAnchor),
            topBarView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])

        NSLayoutConstraint.activate([
            toolBarView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            toolBarView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            toolBarView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            toolBarView.heightAnchor.constraint(equalToConstant: 82),
        ])
    }
    
    func configureViews() {
        overrideUserInterfaceStyle = .dark
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - : TopBarViewDelegate

extension CanvasViewController: CanvasTopBarViewDelegate {
    func resetZoomScaleButtonAction() {
        print(#function)
    }
    
    func clearAllButtonAction() {
        canvasView.clearCanvas()
    }
    
    func undoButtonAction() {
        print(#function)
    }
}

// MARK: - : UIScrollViewDelegate

extension CanvasViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvasView
    }
}

// MARK: - : ToolBarViewDelegate

extension CanvasViewController: CanvasToolBarViewDelegate {
    func canvasToolBarViewActiveToolChanged(_ canvasToolBarView: CanvasToolBarView) {
        let newActiveTool = canvasToolBarView.activeTool
        canvasView.tool = newActiveTool
    }
}
