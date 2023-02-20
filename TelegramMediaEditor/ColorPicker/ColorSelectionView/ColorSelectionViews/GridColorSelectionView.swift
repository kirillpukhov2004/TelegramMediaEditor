import UIKit

// MARK: Constants

fileprivate struct Constants {
    static let colorHexValues: [[Int]] = [[
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
    static let colors: [[UIColor]] = colorHexValues.map { $0.map { UIColor(hex: $0) } }
    static let colorsPerCollumn: Int = 10
    static let colorsPerRow: Int = 12
    static let collectionViewCornerRadius: CGFloat = 8
}

// MARK: GridColorSelectionView

class GridColorSelectionView: UIView, ColorSelectionView {
    private lazy var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.layer.cornerRadius = Constants.collectionViewCornerRadius
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(colorSelected(_:)))
        return tapGestureRecognizer
    }()
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(colorSelected(_:)))
        return panGestureRecognizer
    }()
    
    private lazy var selectedColorViewBorderShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 3
        return shapeLayer
    }()

    public weak var delegate: ColorSelectionViewDelegate?
    
    public var selectedColor: CGColor?  {
        didSet {
            delegate?.colorSelectionViewColorDidChanged(self)
        }
    }
    private var selectedColorView: UIView?

    // MARK: Initialization

    public init() {
        super.init(frame: .zero)
        
        buildViewHierarchy()
        setupLayout()
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let itemSize = calculateCellSize(for: bounds.size)
        collectionViewFlowLayout.itemSize = itemSize
        
        let contentSize = CGSize(width: itemSize.width * Constants.colorsPerRow, height: itemSize.height * Constants.colorsPerCollumn)
        collectionView.bounds = CGRect(origin: collectionView.bounds.origin, size: contentSize)
        
        collectionViewFlowLayout.invalidateLayout()
        
        if let selectedColorView = selectedColorView {
            updateSelectedColorBorder(for: selectedColorView)
        }
    }
    
    // MARK: Actions
    
    @objc private func colorSelected(_ sender: UIGestureRecognizer) {
        let touchLocation = sender.location(in: collectionView)
        
        switch sender.state {
        case .began:
            guard sender.view!.frame.contains(touchLocation) else {
                sender.state = .failed
                return
            }
        case .changed, .ended:
            guard let selectedView = collectionView.hitTest(touchLocation, with: nil) else { return }
            guard let selectedViewBackgroundColor = selectedView.backgroundColor?.cgColor else { return }

            updateSelectedColorBorder(for: selectedView)
            
            selectedColor = selectedViewBackgroundColor
            delegate?.colorSelectionViewColorDidChanged(self)
        default:
            break
        }
    }

    // MARK: Private Functions
    
    private func buildViewHierarchy() {
        addSubview(collectionView)
        
        collectionView.addGestureRecognizer(tapGestureRecognizer)
        collectionView.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            collectionView.heightAnchor.constraint(equalTo: heightAnchor),
            collectionView.widthAnchor.constraint(equalTo: widthAnchor),
        ])
    }
    
    private func configureViews() {
    }
    
    private func updateSelectedColorBorder(for selectedColorView: UIView) {
        guard let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let borderRect = CGRect(origin: .zero, size: collectionViewFlowLayout.itemSize).insetBy(dx: -1.25, dy: -1.25)
        
        let colorRow = selectedColorView.frame.origin.x / selectedColorView.frame.width
        let colorCollumn = selectedColorView.frame.origin.y / selectedColorView.frame.height
        
        let borderOrigin: CGPoint = CGPoint(x: colorRow * collectionViewFlowLayout.itemSize.width + selectedColorView.superview!.frame.origin.x,
                                            y: colorCollumn * collectionViewFlowLayout.itemSize.height + selectedColorView.superview!.frame.origin.y)
        let cornerRadius1: CGFloat = 1.25
        let cornerRadius2: CGFloat = Constants.collectionViewCornerRadius + 1.25

        var bezierPath: UIBezierPath
        switch selectedColorView.backgroundColor {
        case Constants.colors.first?.first:
            bezierPath = UIBezierPath(roundedRect: borderRect,
                                      topLeftRadius: cornerRadius2,
                                      topRightRadius: cornerRadius1,
                                      bottomRightRadius: cornerRadius1,
                                      bottomLeftRadius: cornerRadius1)
        case Constants.colors.first?.last:
            bezierPath = UIBezierPath(roundedRect: borderRect,
                                      topLeftRadius: cornerRadius1,
                                      topRightRadius: cornerRadius2,
                                      bottomRightRadius: cornerRadius1,
                                      bottomLeftRadius: cornerRadius1)
        case Constants.colors.last?.first:
            bezierPath = UIBezierPath(roundedRect: borderRect,
                                      topLeftRadius: cornerRadius1,
                                      topRightRadius: cornerRadius1,
                                      bottomRightRadius: cornerRadius1,
                                      bottomLeftRadius: cornerRadius2)
        case Constants.colors.last?.last:
            bezierPath = UIBezierPath(roundedRect: borderRect,
                                      topLeftRadius: cornerRadius1,
                                      topRightRadius: cornerRadius1,
                                      bottomRightRadius: cornerRadius2,
                                      bottomLeftRadius: cornerRadius1)
        default:
            bezierPath = UIBezierPath(roundedRect: borderRect,
                                      topLeftRadius: cornerRadius1,
                                      topRightRadius: cornerRadius1,
                                      bottomRightRadius: cornerRadius1,
                                      bottomLeftRadius: cornerRadius1)
        }
        
        if selectedColorViewBorderShapeLayer.superlayer == nil {
            layer.addSublayer(selectedColorViewBorderShapeLayer)
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        selectedColorViewBorderShapeLayer.path = bezierPath.cgPath
        selectedColorViewBorderShapeLayer.frame.origin = borderOrigin
        
        CATransaction.commit()
        
        self.selectedColorView = selectedColorView
    }
    
    private func calculateCellSize(for size: CGSize) -> CGSize {
        let availableWidth = size.width
        let itemDimension = floor(availableWidth / Constants.colorsPerRow)
        return CGSize(width: itemDimension, height: itemDimension)
    }
    
    // MARK: Public Functions
    
    public func colorChanged(to color: CGColor) {
        for cell in collectionView.visibleCells {
            if cell.backgroundColor == UIColor(cgColor: color) {
                updateSelectedColorBorder(for: cell)
                return
            }
        }
        selectedColorViewBorderShapeLayer.removeFromSuperlayer()
    }
    
    public func setColor(to color: CGColor) {
        selectedColor = color
    }
    
}

// MARK: - : UICollectionViewDataSource

extension GridColorSelectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.colorsPerCollumn * Constants.colorsPerRow
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let cellColor = Constants.colors[indexPath.row / 12][indexPath.row % 12]
        
        cell.backgroundColor = cellColor
        
        return cell
    }
}
