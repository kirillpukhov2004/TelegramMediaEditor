import UIKit

// MARK: - SavedColorsView

class SavedColorsView: UIView {
    private lazy var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 8
        collectionViewLayout.minimumInteritemSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
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
    
    // MARK: Actions
    
    @objc private func colorSelected(_ sender: UIGestureRecognizer) {
        guard let selectedColorView = sender.view else { return }
        guard let selectedColor = selectedColorView.backgroundColor else { return }
        lastSelectedColor = selectedColor.cgColor
        delegate?.savedColorsViewColorSelected(self)
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
}

// MARK: - : UICollectionViewDataSource

extension SavedColorsView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.layer.backgroundColor = savedColors[indexPath.row]
        cell.layer.cornerRadius = cell.frame.width / 2
        
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(colorSelected(_:)))
        cell.addGestureRecognizer(tapGestureRecognizer)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SavedColorsView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availdableHeight: CGFloat = collectionView.bounds.height - (collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing * 3
        let availableWidth: CGFloat = collectionView.bounds.width - (collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing * (savedColors.count + 1)
        let squareDimension: CGFloat = min(availableWidth / 2, availdableHeight / 2)
        
        return CGSize(width: squareDimension, height: squareDimension)
    }
}
