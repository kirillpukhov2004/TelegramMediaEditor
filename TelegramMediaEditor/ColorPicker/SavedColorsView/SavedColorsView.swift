import UIKit

// MARK: - Constants

fileprivate enum Constants {
    static let savedColors = "savedColors"
}

// MARK: - SavedColorsView

class SavedColorsView: UIView {
    private lazy var collectionViewLayout: UICollectionViewCompositionalLayout = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalHeight(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5))
        let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: nestedGroupSize, subitems: [item])
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [nestedGroup])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, offset, environment in
            guard let strongSelf = self else { return }
            
            let _ = round(offset.x / strongSelf.collectionView.bounds.width * 100) / 100
        }
        
        return UICollectionViewCompositionalLayout(section: section)
    }()
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.register(SavedColorsCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    private var collectionViewDiffableDataSource: UICollectionViewDiffableDataSource<Int, Date>!
    
    public var delegate: SavedColorsViewDelegate?
    
    private lazy var colorsDict: [Date: CGColor] = restoreColors() {
        didSet {
            saveColors(colorsDict)
            applySnapshot()
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
        
        guard let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewCompositionalLayout else { return }
        collectionViewLayout.invalidateLayout()
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
        configureDataSource()
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Date>()
        
        snapshot.appendSections([0])
        
        var items = colorsDict.keys.sorted(by: <)
        items.append(Date(timeIntervalSince1970: .infinity))
        snapshot.appendItems(items)
        
        collectionViewDiffableDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func configureDataSource() {
        collectionViewDiffableDataSource = UICollectionViewDiffableDataSource<Int, Date>(collectionView: collectionView) { [weak self] collectionView, indexPath, itemIdentifier in
            guard let strongSelf = self else { return UICollectionViewCell() }
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? SavedColorsCollectionViewCell else { fatalError() }
            
            if indexPath.row == (collectionView.numberOfItems(inSection: 0) - 1) {
                cell.configure(withColor: UIColor.secondarySystemBackground.cgColor, isButton: true)
                
                let symbolConfiguration = UIImage.SymbolConfiguration(weight: .semibold)
                let plusImage = UIImage(systemName: "plus", withConfiguration: symbolConfiguration)!.withTintColor(.label, renderingMode: .alwaysOriginal)
                let imageView = UIImageView(image: plusImage)
                imageView.frame = cell.bounds.insetBy(dx: cell.bounds.height * 0.175, dy: cell.bounds.height * 0.175)
                imageView.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleHeight, .flexibleWidth]
                imageView.contentMode = .scaleAspectFit
                cell.contentView.addSubview(imageView)
                
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(strongSelf.plusButtonPressed))
                cell.addGestureRecognizer(tapGestureRecognizer)
            } else {
                cell.configure(withColor: strongSelf.colorsDict[itemIdentifier]!)
            }
            
            return cell
        }
        
        applySnapshot()
    }
    
    private func saveColors(_ cgColorsDict: [Date: CGColor]) {
        var colorsDict = [Date: Color]()
        
        for (key, value) in cgColorsDict {
            colorsDict[key] = Color(cgColor: value)
        }
        
        colorsDict.save(Constants.savedColors)
    }
    
    private func restoreColors() -> [Date: CGColor] {
        let defaultColorsDict = [Date().addingTimeInterval(1): UIColor.red.cgColor, Date().addingTimeInterval(2): UIColor.green.cgColor, Date().addingTimeInterval(3): UIColor.blue.cgColor]
        
        guard let colorsDict = Dictionary<Date, Color>.restore(Constants.savedColors) else {
            return defaultColorsDict
        }
        
        var cgColorsDict =  [Date: CGColor]()
        for (key, value) in colorsDict {
            cgColorsDict[key] = value.cgColor
        }
        
        return cgColorsDict
    }
    
    // MARK: Public Functions
    
    public func saveColor(_ color: CGColor) {
        colorsDict[Date()] = color
    }
}

extension SavedColorsView: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if indexPath.row != collectionView.numberOfItems(inSection: 0) - 1 {
            guard let cell = collectionView.cellForItem(at: indexPath) as? SavedColorsCollectionViewCell else { return }
            
            let color = cell.getColor()
            lastSelectedColor = color
            delegate?.savedColorsViewColorSelected(self)
        }
    }
}
