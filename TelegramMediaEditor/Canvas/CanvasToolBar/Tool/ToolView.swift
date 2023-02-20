import UIKit

// MARK: - ToolView

class ToolView: UIView {
    private(set) var tool: Tool
    
    private var toolView: UIView!
    
    private lazy var widthIndicatorView: UIView = {
        let view = UIView()

        return view
    }()
    private lazy var widthIndicatorGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        return gradientLayer
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
        setupLayout()
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private Functions
    
    private func buildViewHierarchy() {
        addSubview(toolView)
        addSubview(widthIndicatorView)
        widthIndicatorView.layer.addSublayer(widthIndicatorGradientLayer)
    }
    
    private func setupLayout() {
        toolView.frame = bounds
        toolView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        if tool.haveWidthIndicator, let toolWidth = tool.width {
            widthIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            widthIdicatorViewTopAnchor = widthIndicatorView.topAnchor.constraint(equalTo: toolView.centerYAnchor)
            widthIdicatorViewHeightAnchor = widthIndicatorView.heightAnchor.constraint(equalToConstant: toolWidth)
            widthIndicatorViewWidthAnchor = widthIndicatorView.widthAnchor.constraint(equalTo: toolView.widthAnchor)
            NSLayoutConstraint.activate([
                widthIdicatorViewTopAnchor,
                widthIndicatorView.centerXAnchor.constraint(equalTo: toolView.centerXAnchor),
                widthIdicatorViewHeightAnchor,
                widthIndicatorViewWidthAnchor,
            ])
            
        }
    }
    
    private func configureViews() {
        widthIndicatorView.isHidden = !tool.haveWidthIndicator
        switch tool {
        case .pen(_, _), .brush(_, _), .neon(_, _), .pencil(_, _):
            setColor(to: tool.color!)
        default:
            break
        }
    }
    
    // MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()

        guard tool.haveWidthIndicator else { return }

        let widthScaleFactor = toolView.frame.size.width / tool.baseImageView.image!.size.width
        let heightScaleFactor = toolView.frame.size.height / tool.baseImageView.image!.size.height
        let scaleFactor = min(widthScaleFactor, heightScaleFactor)
        
        widthIdicatorViewTopAnchor.constant = -24 / tool.baseImageView.contentScaleFactor * scaleFactor
        widthIndicatorViewWidthAnchor.constant = -18 / tool.baseImageView.contentScaleFactor * widthScaleFactor * (toolView.frame.width == 40 ? 3 : 1)
        widthIndicatorGradientLayer.frame = widthIndicatorView.bounds
    }
    
    // MARK: Public Functions
    
    public func setWidth(to width: CGFloat, minWidth: CGFloat, maxWidth: CGFloat) {
        tool.width = width
        widthIdicatorViewHeightAnchor.constant = 1 + ((width - minWidth) / (maxWidth - minWidth)) * (20 - 1)
    }
    
    public func setColor(to color: CGColor) {
        tool.color = color
        toolView.tintColor = UIColor(cgColor: color)
        
        let locations: [NSNumber]
        let colors: [CGColor]
    
        switch tool {
        case .pencil(_, _):
            locations = [0, 0.3, 0.7, 1]
            colors = [
                UIColor(cgColor: color).withMultipliedBrightnessBy(0.6).cgColor,
                color,
                color,
                UIColor(cgColor: color).withMultipliedBrightnessBy(0.6).cgColor,
            ]
        default:
            locations = [0, 0.15, 0.85, 1]
            colors = [
                UIColor(cgColor: color).withMultipliedBrightnessBy(0.7).cgColor,
                color,
                color,
                UIColor(cgColor: color).withMultipliedBrightnessBy(0.7).cgColor,
            ]
        }
        
        widthIndicatorGradientLayer.locations = locations
        widthIndicatorGradientLayer.colors = colors
    }
}
