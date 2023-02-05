import UIKit

// MARK: - SavedColorsView

class SavedColorsView: UIView {
    private lazy var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 8
        collectionViewLayout.minimumInteritemSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(SavedColorsCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    public var delegate: SavedColorsViewDelegate?
    
    public var savedColors: [CGColor] = [UIColor.red.cgColor, UIColor.green.cgColor, UIColor.blue.cgColor] {
        didSet {
            collectionView.reloadData()
        }
    }
    private(set) var lastSelectedColor: CGColor?
    
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
    
    // MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        collectionViewFlowLayout.itemSize = calculateCellSize(for: bounds.size)
        collectionViewFlowLayout.invalidateLayout()
    }
    
    // MARK: Actions
    
    @objc private func colorSelected(_ sender: UIGestureRecognizer) {
        guard let selectedColorView = sender.view else { return }
        guard let selectedColor = selectedColorView.backgroundColor else { return }
        lastSelectedColor = selectedColor.cgColor
        delegate?.savedColorsViewColorSelected(self)
    }
    
    @objc private func plusButtonPressed() {
        delegate?.savedColorsViewPlusButtonPressed(self)
    }
    
    @objc private func colorLongPressed(_ sender: UIGestureRecognizer) {
        guard let pressedView = sender.view as? UICollectionViewCell else { return }
        guard let index = collectionView.indexPath(for: pressedView)?.row else { return }
        savedColors.remove(at: index)
    }
    
    // MARK: Private Functions
    
    private func buildViewHierarchy() {
        addSubview(collectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.heightAnchor.constraint(equalTo: heightAnchor),
            collectionView.widthAnchor.constraint(equalTo: widthAnchor),
        ])
    }
    
    private func configureViews() {
        
    }
    
    private func calculateCellSize(for size: CGSize) -> CGSize {
        let collectionViewLayout = collectionView.collectionViewLayout
        let availdableHeight = bounds.height - (collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing * 3
        let availableWidth = bounds.width - (collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing * (savedColors.count + 1)
        let squareDimension = min(availableWidth / 2, availdableHeight / 2)
        return CGSize(width: squareDimension, height: squareDimension)
    }
    
    // MARK: Public Functions
}

// MARK: - : UICollectionViewDataSource

extension SavedColorsView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedColors.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.gestureRecognizers?.forEach { cell.removeGestureRecognizer($0) }
        cell.backgroundColor = .clear
        
        if indexPath.row == collectionView.numberOfItems(inSection: collectionView.numberOfSections - 1) - 1 {
            cell.layer.backgroundColor = UIColor.secondarySystemBackground.cgColor
            
            let symbolConfiguration = UIImage.SymbolConfiguration(weight: .semibold)
            let plusImage = UIImage(systemName: "plus", withConfiguration: symbolConfiguration)!.withTintColor(.label, renderingMode: .alwaysOriginal)
            let imageView = UIImageView(image: plusImage)
            imageView.frame = cell.bounds.insetBy(dx: cell.bounds.height * 0.175, dy: cell.bounds.height * 0.175)
            imageView.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleHeight, .flexibleWidth]
            imageView.contentMode = .scaleAspectFit
            cell.contentView.addSubview(imageView)
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(plusButtonPressed))
            cell.addGestureRecognizer(tapGestureRecognizer)
        } else {
            cell.layer.backgroundColor = savedColors[indexPath.row]
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(colorSelected(_:)))
            cell.addGestureRecognizer(tapGestureRecognizer)
            
            let longGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(colorLongPressed(_:)))
            cell.addGestureRecognizer(longGestureRecognizer)
        }

        return cell
    }
}
