import UIKit

class ToolView: UIView {
    private(set) var tool: Tool
    
    private var baseImageView: UIImageView
    private var tipImageView: UIImageView
    
    init(for tool: Tool) {
        self.tool = tool
        self.baseImageView = UIImageView()
        self.tipImageView = UIImageView()
        
        super.init(frame: .zero)
        
        configureViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        baseImageView.clipsToBounds = true
        baseImageView.image = tool.type.baseImage
        
        tipImageView.clipsToBounds = true
        tipImageView.image = tool.type.tipImage
        
        addSubview(baseImageView)
        addSubview(tipImageView)
    }
    
    private func setupConstraints() {
        baseImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            baseImageView.topAnchor.constraint(equalTo: topAnchor),
            baseImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            baseImageView.heightAnchor.constraint(equalTo: heightAnchor),
            baseImageView.widthAnchor.constraint(equalTo: widthAnchor),
        ])
        
        tipImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tipImageView.topAnchor.constraint(equalTo: topAnchor),
            tipImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            tipImageView.heightAnchor.constraint(equalTo: heightAnchor),
            tipImageView.widthAnchor.constraint(equalTo: widthAnchor),
        ])
    }
}
