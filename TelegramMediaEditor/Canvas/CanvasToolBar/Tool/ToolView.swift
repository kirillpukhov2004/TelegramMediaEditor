import UIKit

// MARK: - ToolView

class ToolView: UIView {
    private(set) var tool: Tool
    
    private var toolView: UIView!
    
    private lazy var widthIdicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var widthIdicatorViewHeightAnchor: NSLayoutConstraint!
    private var widthIdicatorViewTopAnchor: NSLayoutConstraint!
    private var widthIndicatorViewWidthAnchor: NSLayoutConstraint!
        
    // MARK: Initialization
    
    public init(for tool: Tool) {
        self.tool = tool
        toolView = tool.view
        
        super.init(frame: .zero)
        
        buildViewHierarchy()
        setupConstraints()
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private Functions
    
    private func buildViewHierarchy() {
        addSubview(toolView)
        addSubview(widthIdicatorView)
    }
    
    private func setupConstraints() {
        toolView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toolView.heightAnchor.constraint(equalTo: heightAnchor),
            toolView.widthAnchor.constraint(equalTo: widthAnchor),
        ])
        
        if let toolWidth = tool.width {
            widthIdicatorViewTopAnchor = widthIdicatorView.topAnchor.constraint(equalTo: toolView.centerYAnchor)
            widthIdicatorViewHeightAnchor = widthIdicatorView.heightAnchor.constraint(equalToConstant: toolWidth)
            widthIndicatorViewWidthAnchor = widthIdicatorView.widthAnchor.constraint(equalTo: toolView.widthAnchor)
            NSLayoutConstraint.activate([
                widthIdicatorViewTopAnchor,
                widthIdicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
                widthIdicatorViewHeightAnchor,
                widthIndicatorViewWidthAnchor,
            ])
        }
    }
    
    private func configureViews() {
        widthIdicatorView.isHidden = (tool.width == nil)
    }
    
    // MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()

        guard tool.width != nil else { return }
        
        let widthScaleFactor = toolView.frame.size.width / tool.baseImageView.image!.size.width
        let heightScaleFactor = toolView.frame.size.height / tool.baseImageView.image!.size.height
        let scaleFactor = min(widthScaleFactor, heightScaleFactor)

        widthIdicatorViewTopAnchor.constant = -24 / tool.baseImageView.contentScaleFactor * scaleFactor
        widthIndicatorViewWidthAnchor.constant = -18 / tool.baseImageView.contentScaleFactor * widthScaleFactor * (tool.baseImageView.frame.width == 40 ? 3 : 1)
    }
    
    // MARK: Public Functions
    
    public func setWidth(to width: CGFloat, minWidth: CGFloat, maxWidth: CGFloat) {
        tool.width = width
        widthIdicatorViewHeightAnchor.constant = 1 + ((width - minWidth) / (maxWidth - minWidth)) * (20 - 1)
    }
    
    public func setColor(to color: CGColor) {
        tool.color = color
        toolView.tintColor = UIColor(cgColor: color)
        widthIdicatorView.backgroundColor = UIColor(cgColor: color)
    }
}
