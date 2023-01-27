import UIKit

// MARK: - Constants

fileprivate struct Constants {
    static let colorGridHexValues: [[Int]] = [[
        0xFEFFFE, 0xEBEBEB, 0xD6D6D6, 0xC2C2C2, 0xADADAD, 0x999999, 0x858585, 0x707070, 0x5C5C5C, 0x474747, 0x333333, 0x000000,
    ], [
        0x00374A, 0x011D57, 0x11053B, 0x2E063D, 0x3C071B, 0x5C0701, 0x5A1C00, 0x583300, 0x563D00, 0x666100, 0x4F5504, 0x263E0F,
    ], [
        0x004D65, 0x012F7B, 0x1A0A52, 0x450D59, 0x551029, 0x831100, 0x7B2900, 0x7A4A00, 0x785800, 0x8D8602, 0x6F760A, 0x38571A,
    ], [
        0x016E8F, 0x0042A9, 0x2C0977, 0x61187C, 0x791A3D, 0xB51A00, 0xAD3E00, 0xA96800, 0xA67B01, 0xC4BC00, 0x9BA50E, 0x4E7A27,
    ], [
        0x008CB4, 0x0056D6, 0x371A94, 0x7A219E, 0x99244F, 0xE22400, 0xDA5100, 0xD38301, 0xD19D01, 0xF5EC00, 0xC3D117, 0x669D34,
    ], [
        0x00A1D8, 0x0061FD, 0x4D22B2, 0x982ABC, 0xB92D5D, 0xFF4015, 0xFF6A00, 0xFFAB01, 0xFCC700, 0xFEFB41, 0xD9EC37, 0x76BB40,
    ], [
        0x01C7FC, 0x3A87FD, 0x5E30EB, 0xBE38F3, 0xE63B7A, 0xFE6250, 0xFE8648, 0xFEB43F, 0xFECB3E, 0xFFF76B, 0xE4EF65, 0x96D35F,
    ], [
        0x52D6FC, 0x74A7FF, 0x864FFD, 0xD357FE, 0xEE719E, 0xFF8C82, 0xFEA57D, 0xFEC777, 0xFED977, 0xFFF994, 0xEAF28F, 0xB1DD8B,
    ], [
        0x93E3FC, 0xA7C6FF, 0xB18CFE, 0xE292FE, 0xF4A4C0, 0xFFB5AF, 0xFFC5AB, 0xFED9A8, 0xFDE4A8, 0xFFFBB9, 0xF1F7B7, 0xCDE8B5,
    ], [
        0xCBF0FF, 0xD2E2FE, 0xD8C9FE, 0xEFCAFE, 0xF9D3E0, 0xFFDAD8, 0xFFE2D6, 0xFEECD4, 0xFEF1D5, 0xFDFBDD, 0xF6FADB, 0xDEEED4,
    ]]
    static let colorGridColors: [[UIColor]] = colorGridHexValues.map { $0.map { UIColor(hex: $0) } }
    
    static let colorsInCollumn: Int = colorGridHexValues.count
    static let colorsInRow: Int = colorGridHexValues.first!.count
    
    static let colorSquareSize: CGSize = CGSize(width: 30, height: 30)
    
    static let selectedColorIndicatorSize: CGSize = CGSize(width: 82, height: 82)
}

// MARK: - ColorPickerViewController

class ColorPickerViewController: UIViewController {
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
    
    private lazy var segmentedControl: UISegmentedControl = {
        let items = ["Grid", "Spectrum", "Sliders"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    private lazy var colorGridCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .vertical
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.itemSize = Constants.colorSquareSize
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.dataSource = self
        collectionView.layer.cornerRadius = 8
        collectionView.isPrefetchingEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var topBarStrackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var selectedColorIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(cgColor: selectedColor)
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private(set) var selectedColor: CGColor {
        willSet {
            UIView.animate(withDuration: 0.15, delay: 0) { [weak self] in
                self?.selectedColorIndicatorView.backgroundColor = UIColor(cgColor: newValue)
            }
        }
    }
    
    public var delegate: ColorPickerViewControllerDelegate?
    
    // MARK: Initializaiton
    
    public init(_ initialColor: CGColor) {
        self.selectedColor = initialColor
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    private func buildViewHierarchy() {
        topBarStrackView.addArrangedSubview(eyeDropperButton)
        topBarStrackView.addArrangedSubview(topBarLabel)
        topBarStrackView.addArrangedSubview(closeButton)
        view.addSubview(topBarStrackView)
        
        view.addSubview(segmentedControl)
        
        view.addSubview(colorGridCollectionView)
        
        view.addSubview(selectedColorIndicatorView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            topBarStrackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            topBarStrackView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            topBarStrackView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            topBarStrackView.heightAnchor.constraint(equalToConstant: 54),
        ])
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: topBarStrackView.layoutMarginsGuide.bottomAnchor),
            segmentedControl.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            segmentedControl.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 28),
        ])
        
        NSLayoutConstraint.activate([
            colorGridCollectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            colorGridCollectionView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            colorGridCollectionView.heightAnchor.constraint(equalToConstant: Constants.colorsInCollumn * Constants.colorSquareSize.height),
            colorGridCollectionView.widthAnchor.constraint(equalToConstant: Constants.colorsInRow * Constants.colorSquareSize.width),
        ])
        
        NSLayoutConstraint.activate([
            selectedColorIndicatorView.bottomAnchor.constraint(equalTo: colorGridCollectionView.bottomAnchor),
            selectedColorIndicatorView.leftAnchor.constraint(equalTo: colorGridCollectionView.rightAnchor, constant: 20),
            selectedColorIndicatorView.heightAnchor.constraint(equalToConstant: Constants.selectedColorIndicatorSize.height),
            selectedColorIndicatorView.widthAnchor.constraint(equalToConstant: Constants.selectedColorIndicatorSize.width),
        ])
    }
    
    private func configureViews() {
        
    }
    
    // MARK: Actions
    
    @objc func closeButtonPressed() {
        dismiss(animated: true)
    }
    
    @objc func colorSelected(_ sender: UIGestureRecognizer) {
        guard let selectedView = sender.view else { return }
        guard let backgroundColor = selectedView.backgroundColor?.cgColor else { return }
        selectedColor = backgroundColor
        delegate?.colorChanged(self)
    }
}

// MARK: - : UICollectionViewDataSource

extension ColorPickerViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 12 * 10
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        let rowNumber = indexPath.row / 12
        let collumnNumber = indexPath.row % 12
        cell.backgroundColor = Constants.colorGridColors[rowNumber][collumnNumber]
        
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(colorSelected(_:)))
        cell.addGestureRecognizer(tapGestureRecognizer)
        
        return cell
    }
}
