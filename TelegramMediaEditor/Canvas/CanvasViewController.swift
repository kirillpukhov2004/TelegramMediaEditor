import UIKit

class CanvasViewController: UIViewController {
    lazy var clearAllButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var resetZoomScaleButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var undoButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var canvasView: CanvasView = {
        let canvasView = CanvasView(toolBarView.activeTool)
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        return canvasView
    }()
    lazy var toolBarView: ToolBarView = {
        let toolBarView = ToolBarView()
        toolBarView.translatesAutoresizingMaskIntoConstraints = false
        return toolBarView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildViewHierarchy()
        setupConstraints()
        configureViews()
    }
    
    func buildViewHierarchy() {
        view.addSubview(canvasView)
        view.addSubview(toolBarView)
    }
    
    func configureViews() {
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            canvasView.rightAnchor.constraint(equalTo: view.rightAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            canvasView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])
        
        NSLayoutConstraint.activate([
            toolBarView.rightAnchor.constraint(equalTo: view.rightAnchor),
            toolBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            toolBarView.leftAnchor.constraint(equalTo: view.leftAnchor),
            toolBarView.heightAnchor.constraint(equalToConstant: 82),
        ])
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
