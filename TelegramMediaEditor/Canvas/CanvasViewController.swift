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
    lazy var canvasView: CanvasView = {
        let canvasView = CanvasView(toolBarView.activeTool)
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        return canvasView
    }()
    lazy var topBarView: TopBarView = {
        let topBarView = TopBarView()
        topBarView.delegate = self
        topBarView.translatesAutoresizingMaskIntoConstraints = false
        return topBarView
    }()
    lazy var toolBarView: ToolBarView = {
        let toolBarView = ToolBarView()
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
    
    func buildViewHierarchy() {
        view.addSubview(canvasView)
        view.addSubview(topBarView)
        view.addSubview(toolBarView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor,
                                            constant: Constants.canvasEdgeInsets.top),
            canvasView.rightAnchor.constraint(equalTo: view.rightAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                               constant: Constants.canvasEdgeInsets.bottom),
            canvasView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])
        
        NSLayoutConstraint.activate([
            topBarView.topAnchor.constraint(equalTo: view.topAnchor),
            topBarView.rightAnchor.constraint(equalTo: view.rightAnchor),
            topBarView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])
        
        NSLayoutConstraint.activate([
            toolBarView.rightAnchor.constraint(equalTo: view.rightAnchor),
            toolBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            toolBarView.leftAnchor.constraint(equalTo: view.leftAnchor),
            toolBarView.heightAnchor.constraint(equalToConstant: 82),
        ])
    }
    
    func configureViews() {
        overrideUserInterfaceStyle = .dark
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - : TopBarViewDelegate

extension CanvasViewController: TopBarViewDelegate {
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

// MARK: - : ToolBarViewDelegate

extension CanvasViewController: ToolBarViewDelegate {
    func activeToolUpdated(_ tool: Tool) {
        canvasView.tool = tool
    }
}
