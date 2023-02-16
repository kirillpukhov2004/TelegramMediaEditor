import UIKit
import Photos
import Lottie

class PickerAccessRequestViewController: UIViewController {
    lazy var lottieAnimationView: LottieAnimationView = {
        let lottieAnimation = LottieAnimation.named("Lottie/duck", animationCache: LRUAnimationCache.sharedCache)
        
        let lottieAnimationView = LottieAnimationView()
        lottieAnimationView.animation = lottieAnimation
        lottieAnimationView.loopMode = .loop
        
        return lottieAnimationView
    }()
    lazy var promptLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Access Your Photos and Videos"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        
        return label
    }()
    lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Allow Access", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 10.0
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        button.backgroundColor = UIColor(cgColor: CGColor(red: 0, green: 0.478, blue: 1, alpha: 1))
        
        return button
    }()
    lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        lottieAnimationView.play()
    }
    
    // MARK: Actions
    
    @objc private func buttonPressed() {
        PHPhotoLibrary.requestAuthorization { [weak self] authorizationStatus in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                if authorizationStatus != .denied {
                    if strongSelf.navigationController?.viewControllers.count == 1 {
                        let imagePickerViewController = PickerViewController()
                        strongSelf.navigationController?.pushViewController(imagePickerViewController, animated: true)
                    }
                }
            }
        }
    }
    
    // MARK: Private Functions
    
    private func buildViewHierarchy() {
        view.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(lottieAnimationView)
        verticalStackView.addArrangedSubview(promptLabel)
        verticalStackView.addArrangedSubview(button)
    }
    
    private func setupConstraints() {
        lottieAnimationView.translatesAutoresizingMaskIntoConstraints = false
        let lottieAnimationViewSize = CGSize(width: 144, height: 144)
        NSLayoutConstraint.activate([
            lottieAnimationView.heightAnchor.constraint(equalToConstant: lottieAnimationViewSize.height),
            lottieAnimationView.widthAnchor.constraint(equalToConstant: lottieAnimationViewSize.width),
        ])
        
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        let promptLabelSize = CGSize(width: 289, height: 24)
        let promptLabelTopSpacing: CGFloat = 20
        NSLayoutConstraint.activate([
            promptLabel.heightAnchor.constraint(equalToConstant: promptLabelSize.height),
            promptLabel.widthAnchor.constraint(equalToConstant: promptLabelSize.width),
        ])
        verticalStackView.setCustomSpacing(promptLabelTopSpacing, after: lottieAnimationView)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonSize = CGSize(width: 358, height: 50)
        let buttonTopSpacing: CGFloat = 28
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: buttonSize.height),
            button.widthAnchor.constraint(equalToConstant: buttonSize.width),
        ])
        verticalStackView.setCustomSpacing(buttonTopSpacing, after: promptLabel)
        
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            verticalStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func configureViews() {
        overrideUserInterfaceStyle = .dark
    }
}
