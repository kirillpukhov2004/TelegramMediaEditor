import UIKit

class ToolView: UIView {
    private(set) var tool: Tool
    
    private lazy var baseImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var tipImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var widthIdicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(cgColor: tool.color)
//        view.layer.cornerRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var widthIdicatorViewHeightAnchor: NSLayoutConstraint!
    private var widthIdicatorViewTopAnchor: NSLayoutConstraint!
    private var widthIndicatorViewWidthAnchor: NSLayoutConstraint!
        
    init(for tool: Tool) {
        self.tool = tool
        
        super.init(frame: .zero)
        
        buildViewHierarchy()
        setupConstraints()
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let widthScaleFactor = baseImageView.frame.size.width / baseImageView.image!.size.width
        let heightScaleFactor = baseImageView.frame.size.height / baseImageView.image!.size.height
        let scaleFactor = min(widthScaleFactor, heightScaleFactor)
        
        widthIdicatorViewTopAnchor.constant = -24 / baseImageView.contentScaleFactor * scaleFactor
        widthIndicatorViewWidthAnchor.constant = -18 / baseImageView.contentScaleFactor * widthScaleFactor * (baseImageView.frame.width == 40 ? 3 : 1)
    }
    
    private func buildViewHierarchy() {
        addSubview(baseImageView)
        addSubview(tipImageView)
        addSubview(widthIdicatorView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            baseImageView.heightAnchor.constraint(equalTo: heightAnchor),
            baseImageView.widthAnchor.constraint(equalTo: widthAnchor),
        ])
    
        NSLayoutConstraint.activate([
            tipImageView.heightAnchor.constraint(equalTo: heightAnchor),
            tipImageView.widthAnchor.constraint(equalTo: widthAnchor),
        ])
        
        widthIdicatorViewTopAnchor = widthIdicatorView.topAnchor.constraint(equalTo: baseImageView.centerYAnchor)
        widthIdicatorViewHeightAnchor = widthIdicatorView.heightAnchor.constraint(equalToConstant: tool.width)
        widthIndicatorViewWidthAnchor = widthIdicatorView.widthAnchor.constraint(equalTo: baseImageView.widthAnchor)
        NSLayoutConstraint.activate([
            widthIdicatorViewTopAnchor,
            widthIdicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            widthIdicatorViewHeightAnchor,
            widthIndicatorViewWidthAnchor,
        ])
    }
    
    private func configureViews() {
        baseImageView.image = tool.type.baseImage
        tipImageView.image = tool.type.tipImage
        
        widthIdicatorView.isHidden = !tool.type.haveWidth
    }
    
    public func setToolWidth(to width: CGFloat) {
        tool.width = width
        widthIdicatorViewHeightAnchor.constant = width
    }
    
    public func setToolColor(to color: CGColor) {
        tool.color = color
    }
}
