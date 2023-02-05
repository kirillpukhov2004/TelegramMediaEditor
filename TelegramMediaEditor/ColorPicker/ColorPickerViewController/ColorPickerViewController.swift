import UIKit

// MARK: - Constants

fileprivate struct Constants {
    static let topBarHeight: CGFloat = 54
    static let segmentedControlHeight: CGFloat = 28
    
    static let sliderSize = CGSize(width: 269, height: 36)
    static let sliderThumbSize = CGSize(width: 29, height: 29)
    static let colorViewIndicatorSize = CGSize(width: 82, height: 82)
}

// MARK: - ColorPickerViewController

class ColorPickerViewController: UIViewController {
    private lazy var topBarStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private lazy var topBarLabel: UILabel = {
        let label = UILabel()
        label.text = "Colors"
        label.font = .preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var eyeDropperButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eyedropper")!, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var closeButton: UIButton = {
        let image = UIImage(systemName: "xmark")!.withTintColor(.label, renderingMode: .alwaysOriginal)
        let button = UIButton(type: .custom)
        button.setBackgroundImage(image , for: .normal)
        button.addTarget(self, action: #selector(closeButtonPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var colorSelectionView: ColorSelectionView = {
        let colorsSelectionView = GridColorSelectionView()
        colorsSelectionView.delegate = self
        colorsSelectionView.translatesAutoresizingMaskIntoConstraints = false
        return colorsSelectionView
    }()
    
    private lazy var segmentedControl: SegmentedControl = {
        let items = ["Grid", "Spectrum", "Sliders"]
        let segmentedControl = SegmentedControl()
        segmentedControl.setSegments(items)
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    private lazy var opacitySlider: Slider = {
        let slider = Slider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.step = 0.01
        slider.value = color.alpha
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.setTrackLayer(to: opacitySliderTrackLayer(for: colorSelectionView.selectedColor ?? color.copy(alpha: 1)!))
        slider.setThumbLayer(to: opacitySliderThumbLayer(for: color))
        slider.layer.cornerRadius = Constants.sliderSize.height / 2
        slider.clipsToBounds = true
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    private lazy var savedColorsView: SavedColorsView = {
        let savedColorsView = SavedColorsView()
        savedColorsView.delegate = self
        savedColorsView.translatesAutoresizingMaskIntoConstraints = false
        return savedColorsView
    }()
    
    private(set) var color: CGColor {
        didSet {
            updateViewColors()
            delegate?.colorPickerViewControllerColorChanged(self)
        }
    }
    
    private lazy var selectedColorIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(cgColor: color)
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var portraitConstraints: [NSLayoutConstraint] = calculatePortraitConstraints()
    private lazy var landscapeConstraints: [NSLayoutConstraint] = calculateLandscapeConstraints()
    
    public var delegate: ColorPickerViewControllerDelegate?
    
    // MARK: Initializaiton
    
    public init(_ color: CGColor) {
        self.color = color
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        overrideUserInterfaceStyle = .dark
        
        buildViewHierarchy()
        setupConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.updateConstraints()
        })
    }
    
    // MARK: Actions
    
    @objc private func closeButtonPressed() {
        dismiss(animated: true)
    }
    
    @objc private func colorSelected(_ gestureRecognizer: UIGestureRecognizer) {

    }
    
    @objc private func segmentedControlValueChanged(_ segmentedControl: SegmentedControl) {
        let newColorSelectionView: ColorSelectionView
        
        guard let selectedSegmentIndex = segmentedControl.selectedSegmentIndex else { return }
        switch selectedSegmentIndex {
        case 0:
            newColorSelectionView = GridColorSelectionView()
        case 1:
            newColorSelectionView = SpectrumColorSelectionView()
        case 2:
            newColorSelectionView = SlidersColorSelectionView()
        default:
            return
        }
        
        newColorSelectionView.delegate = self
        newColorSelectionView.translatesAutoresizingMaskIntoConstraints = false
        
        colorSelectionView.removeFromSuperview()
        colorSelectionView = newColorSelectionView
        view.addSubview(colorSelectionView)
        recalculateConstraints()
        updateConstraints()
    }
    
    @objc private func sliderValueChanged(_ slider: Slider) {
        color = color.copy(alpha: slider.value)!
    }
    
    // MARK: Private Functions
    
    private func buildViewHierarchy() {
        view.addSubview(topBarStackView)
        topBarStackView.addArrangedSubview(eyeDropperButton)
        topBarStackView.addArrangedSubview(topBarLabel)
        topBarStackView.addArrangedSubview(closeButton)
        
        view.addSubview(segmentedControl)
        view.addSubview(opacitySlider)
        view.addSubview(colorSelectionView)
        view.addSubview(selectedColorIndicatorView)
        view.addSubview(savedColorsView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            topBarStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            topBarStackView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            topBarStackView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            topBarStackView.heightAnchor.constraint(equalToConstant: Constants.topBarHeight),
        ])
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: topBarStackView.layoutMarginsGuide.bottomAnchor),
            segmentedControl.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            segmentedControl.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: Constants.segmentedControlHeight),
        ])
        
        updateConstraints()
    }
    
    private func configureViews() {
        
    }
    
    private func updateConstraints() {
        guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else { return }
        
        if orientation.isPortrait {
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
        } else {
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        }
    }
    
    private func recalculateConstraints() {
        NSLayoutConstraint.deactivate(portraitConstraints + landscapeConstraints)
        portraitConstraints = calculatePortraitConstraints()
        landscapeConstraints = calculateLandscapeConstraints()
    }

    private func calculatePortraitConstraints() -> [NSLayoutConstraint] {
        return [
            colorSelectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            colorSelectionView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            colorSelectionView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            colorSelectionView.heightAnchor.constraint(equalTo: colorSelectionView.widthAnchor, multiplier: 10 / 12),
            
            opacitySlider.topAnchor.constraint(equalTo: colorSelectionView.bottomAnchor, constant: 20),
            opacitySlider.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            opacitySlider.heightAnchor.constraint(equalToConstant: Constants.sliderSize.height),
            opacitySlider.widthAnchor.constraint(equalToConstant: Constants.sliderSize.width),
            
            selectedColorIndicatorView.topAnchor.constraint(equalTo: opacitySlider.bottomAnchor, constant: 20),
            selectedColorIndicatorView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            selectedColorIndicatorView.heightAnchor.constraint(equalToConstant: Constants.colorViewIndicatorSize.height),
            selectedColorIndicatorView.widthAnchor.constraint(equalToConstant: Constants.colorViewIndicatorSize.width),
            
            savedColorsView.topAnchor.constraint(equalTo: selectedColorIndicatorView.topAnchor),
            savedColorsView.rightAnchor.constraint(equalTo: opacitySlider.rightAnchor),
            savedColorsView.leftAnchor.constraint(equalTo: selectedColorIndicatorView.rightAnchor, constant: 36),
            savedColorsView.heightAnchor.constraint(equalTo: selectedColorIndicatorView.heightAnchor),
        ]
    }
    
    private func calculateLandscapeConstraints() -> [NSLayoutConstraint] {
        return [
         colorSelectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
         colorSelectionView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
         colorSelectionView.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 1/2),
         colorSelectionView.heightAnchor.constraint(equalTo: colorSelectionView.widthAnchor, multiplier: 10/12),
         
         opacitySlider.topAnchor.constraint(equalTo: colorSelectionView.topAnchor),
         opacitySlider.leftAnchor.constraint(equalTo: colorSelectionView.rightAnchor, constant: 20),
         opacitySlider.heightAnchor.constraint(equalToConstant: Constants.sliderSize.height),
         opacitySlider.widthAnchor.constraint(equalToConstant: Constants.sliderSize.width),
         
         selectedColorIndicatorView.leftAnchor.constraint(equalTo: colorSelectionView.rightAnchor, constant: 20),
         selectedColorIndicatorView.topAnchor.constraint(equalTo: opacitySlider.bottomAnchor, constant: 20),
         selectedColorIndicatorView.heightAnchor.constraint(equalToConstant: Constants.colorViewIndicatorSize.height),
         selectedColorIndicatorView.widthAnchor.constraint(equalToConstant: Constants.colorViewIndicatorSize.width),
         
         savedColorsView.topAnchor.constraint(equalTo: opacitySlider.bottomAnchor, constant: 20),
         savedColorsView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
         savedColorsView.leftAnchor.constraint(equalTo: selectedColorIndicatorView.rightAnchor, constant: 20),
         savedColorsView.heightAnchor.constraint(equalTo: selectedColorIndicatorView.heightAnchor),
        ]
    }
    
    private func opacitySliderTrackLayer(for color: CGColor) -> CALayer {
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        layer.frame.size = CGSize(width: Constants.sliderSize.width, height: Constants.sliderSize.height)
        
        let backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.colors = [UIColor.clear.cgColor, color]
        backgroundGradientLayer.locations = [-1, 1]
        backgroundGradientLayer.transform = CATransform3DMakeRotation(-(.pi / 2), 0, 0, 1)
        backgroundGradientLayer.frame = layer.bounds
        layer.addSublayer(backgroundGradientLayer)
        
        return layer
    }
    
    private func opacitySliderThumbLayer(for color: CGColor) -> CALayer {
        let horizontalPadding: CGFloat = (Constants.sliderSize.height - Constants.sliderThumbSize.height) / 2
        let layer = CALayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.frame.size = CGSize(width: Constants.sliderThumbSize.width + horizontalPadding * 2, height: Constants.sliderThumbSize.width)
        
        let firstShapeLayer = CAShapeLayer()
        firstShapeLayer.fillColor = UIColor.label.cgColor
        let firstBezierPath = UIBezierPath(arcCenter: CGPoint(x: Constants.sliderThumbSize.width / 2 + horizontalPadding, y: Constants.sliderThumbSize.height / 2),
                                           radius: Constants.sliderThumbSize.width / 2,
                                           startAngle: 0, endAngle: 2 * .pi,
                                           clockwise: true)
        firstShapeLayer.path = firstBezierPath.cgPath
        firstShapeLayer.frame = layer.bounds
        
        let secondShapeLayer = CAShapeLayer()
        secondShapeLayer.fillColor = color
        let secondBezierPath = UIBezierPath(arcCenter: CGPoint(x: Constants.sliderThumbSize.width / 2 + horizontalPadding, y: Constants.sliderThumbSize.height / 2),
                                            radius: Constants.sliderThumbSize.width / 2 - 3,
                                           startAngle: 0, endAngle: 2 * .pi,
                                           clockwise: true)
        secondShapeLayer.path = secondBezierPath.cgPath
        secondShapeLayer.frame = layer.bounds
        
        layer.addSublayer(firstShapeLayer)
        layer.addSublayer(secondShapeLayer)
        return layer
    }
    
    private func updateViewColors() {
        opacitySlider.setTrackLayer(to: opacitySliderTrackLayer(for: color.copy(alpha: 1)!))
        opacitySlider.setThumbLayer(to: opacitySliderThumbLayer(for: color))
        selectedColorIndicatorView.backgroundColor = UIColor(cgColor: color)
    }
    
    // MARK: Public Functions
}


// MARK: - : ColorSelectionViewDelgate

extension ColorPickerViewController: ColorSelectionViewDelegate {
    func colorSelectionViewColorDidChanged(_ colorSelectionView: ColorSelectionView) {
        guard let newColor = colorSelectionView.selectedColor else { return }
        color = newColor.copy(alpha: opacitySlider.value)!
    }
}

// MARK: - : SavedColorsViewDelegate

extension ColorPickerViewController: SavedColorsViewDelegate {
    func savedColorsViewPlusButtonPressed(_ savedColorsView: SavedColorsView) {
        savedColorsView.saveColor(color)
    }
    
    func savedColorsViewColorSelected(_ savedColorsView: SavedColorsView) {
        guard let color = savedColorsView.lastSelectedColor else { return }
        self.color = color
        colorSelectionView.colorChanged(to: color.copy(alpha: 1)!)
        opacitySlider.value = color.alpha
        updateViewColors()
    }
}
