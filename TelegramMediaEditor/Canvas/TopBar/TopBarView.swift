import UIKit

// MARK: - TopBarView

class TopBarView: UIView {
    public lazy var resetZoomScaleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Zoom Out", for: .normal)
        button.setImage(UIImage(named: "zoomOut")!, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.setTitleColor(.secondaryLabel, for: .highlighted)
        button.addTarget(self, action: #selector(resetZoomScaleButtonPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    public lazy var clearAllButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Clear All", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.setTitleColor(.secondaryLabel, for: .highlighted)
        button.addTarget(self, action: #selector(clearAllButtonPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    public lazy var undoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "undo")!, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.setTitleColor(.secondaryLabel, for: .highlighted)
        button.addTarget(self, action: #selector(undoButtonPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    public var delegate: TopBarViewDelegate?
    
    // MARK: Initialization
    
    public init() {
        super.init(frame: .zero)
        
        buildViewHierarchy()
        setupConstraints()
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildViewHierarchy() {
        horizontalStackView.addArrangedSubview(undoButton)
        horizontalStackView.addArrangedSubview(resetZoomScaleButton)
        horizontalStackView.addArrangedSubview(clearAllButton)
        addSubview(horizontalStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            horizontalStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            horizontalStackView.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            horizontalStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            horizontalStackView.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor)
        ])
    }
    
    private func configureViews() {
        
    }
    
    // MARK: Actions
    
    @objc func resetZoomScaleButtonPressed() {
        delegate?.resetZoomScaleButtonAction()
    }
    
    @objc func clearAllButtonPressed() {
        delegate?.clearAllButtonAction()
    }
    
    @objc func undoButtonPressed() {
        delegate?.undoButtonAction()
    }
}

