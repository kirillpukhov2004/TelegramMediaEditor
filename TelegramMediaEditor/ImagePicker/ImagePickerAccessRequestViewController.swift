import UIKit
import Photos
import Lottie

class ImagePickerAccessRequestViewController: UIViewController {
    var animationView: LottieAnimationView!
    var promptLabel: UILabel!
    var button: UIButton!
    var viewWrapper: UIView!
    
    @objc func buttonAction() {
        PHPhotoLibrary.requestAuthorization { [weak self] authorizationStatus in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                if authorizationStatus != .denied {
                    if strongSelf.navigationController?.viewControllers.count == 1 {
                        let imagePickerViewController = ImagePickerViewController()
                        strongSelf.navigationController?.pushViewController(imagePickerViewController, animated: true)
                    }
                }
            }
        }
    }
    
    func initializeViews() {
        view.backgroundColor = .black
        
        let animation = LottieAnimation.named("Lottie/duck", animationCache: LRUAnimationCache.sharedCache)
        animationView = LottieAnimationView()
        animationView.animation = animation
        animationView.loopMode = .loop
        
        promptLabel = UILabel()
        promptLabel.textColor = .white
        promptLabel.text = "Access Your Photos and Videos"
        promptLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        
        button = UIButton()
        button.setTitle("Allow Access", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 10.0
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(buttonAction), for: .touchDown)
        button.backgroundColor = UIColor(cgColor: CGColor(red: 0, green: 0.478, blue: 1, alpha: 1))
        
        viewWrapper = UIView()
        viewWrapper.addSubview(animationView)
        viewWrapper.addSubview(promptLabel)
        viewWrapper.addSubview(button)
        view.addSubview(viewWrapper)
    }
    
    func setupConstraints() {
        animationView.translatesAutoresizingMaskIntoConstraints = false
        let animationViewSize = CGSize(width: 144, height: 144)
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: viewWrapper.topAnchor),
            animationView.heightAnchor.constraint(equalToConstant: animationViewSize.height),
            animationView.widthAnchor.constraint(equalToConstant: animationViewSize.width),
            animationView.centerXAnchor.constraint(equalTo: viewWrapper.centerXAnchor)
        ])
        
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        let promptLabelSize = CGSize(width: 289, height: 24)
        let promptLabelTopSpacing: CGFloat = 20
        NSLayoutConstraint.activate([
            promptLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: promptLabelTopSpacing),
            promptLabel.heightAnchor.constraint(equalToConstant: promptLabelSize.height),
            promptLabel.widthAnchor.constraint(equalToConstant: promptLabelSize.width),
            promptLabel.centerXAnchor.constraint(equalTo: viewWrapper.centerXAnchor)
        ])
        
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonSize = CGSize(width: 358, height: 50)
        let buttonTopSpacing: CGFloat = 28
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: buttonTopSpacing),
            button.heightAnchor.constraint(equalToConstant: buttonSize.height),
            button.widthAnchor.constraint(equalToConstant: buttonSize.width),
            button.centerXAnchor.constraint(equalTo: viewWrapper.centerXAnchor)
        ])
        
        viewWrapper.translatesAutoresizingMaskIntoConstraints = false
        let viewWrapperHeight: CGFloat = animationViewSize.height + promptLabelTopSpacing + promptLabelSize.height + buttonTopSpacing + buttonSize.height
        NSLayoutConstraint.activate([
            viewWrapper.leftAnchor.constraint(equalTo: view.leftAnchor),
            viewWrapper.rightAnchor.constraint(equalTo: view.rightAnchor),
            viewWrapper.heightAnchor.constraint(equalToConstant: viewWrapperHeight),
            viewWrapper.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        
    }
    
    override func loadView() {
        super.loadView()
        
        initializeViews()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animationView.play()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
