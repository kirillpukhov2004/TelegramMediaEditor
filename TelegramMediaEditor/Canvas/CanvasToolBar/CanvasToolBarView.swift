import UIKit

// MARK: - Constants

fileprivate enum Constants {
    static let toolViewsHeight: CGFloat = 88
    static let toolViewsWidth: CGFloat = 240
    
    static let regularToolViewHeight: CGFloat = 88
    static let regularToolViewWidth: CGFloat = 20
    
    static let regularToolViewBottomOffset: CGFloat = 16
    
    static let bigToolViewHeight: CGFloat = 120
    static let bigToolViewWidth: CGFloat = 40
    
    static let toolSelectionAnimationDuration: CGFloat = 0.15
    static let toolCenteringAnimationDuration: CGFloat = 0.9
}

// MARK: - CanvasToolBarView

class CanvasToolBarView: UIView {
    private lazy var toolViews: [ToolView] = {
        let toolsTypesList: [ToolType] = [.pen, .brush, .neon, .pencil, .eraser, .lasso]
        
        var toolsViews = [ToolView]()
        toolsViews = toolsTypesList.map { toolType in
            let tool = Tool(type: toolType, width: 1, color: UIColor.black.cgColor)
            let toolView = ToolView(for: tool)
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toolSelected(_:)))
            toolView.addGestureRecognizer(tapGestureRecognizer)
            toolView.translatesAutoresizingMaskIntoConstraints = false
            return toolView
        }
        return toolsViews
    }()
    private lazy var colorPickerButton: ColorPickerButton = {
        let colorPickerButton = ColorPickerButton(activeTool.color)
        colorPickerButton.delegate = self
        colorPickerButton.translatesAutoresizingMaskIntoConstraints = false
        return colorPickerButton
    }()
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "add")!, for: .normal)
        button.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1)
        button.layer.cornerRadius = 33 / 2
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(addButtonPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "download")!, for: .normal)
        button.addTarget(self, action: #selector(doneButtonPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cancel")!, for: .normal)
        button.addTarget(self, action: #selector(cancelButtonPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var segmentedControl: SegmentedControl = {
        let segmentedControl = SegmentedControl()
        segmentedControl.setSegments(["Draw", "Text"])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    private lazy var slider: Slider = {
        let slider = Slider()
        slider.step = 1
        slider.isHidden = true
        slider.minimumValue = 1
        slider.maximumValue = 25
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private lazy var toolViewsWrapper: UIView = {
        let view = UIView()
        
        let maskGradientLayer = CAGradientLayer()
        maskGradientLayer.colors = [
            CGColor(red: 0, green: 0, blue: 0, alpha: 1),
            CGColor(red: 0, green: 0, blue: 0, alpha: 0),
        ]
        maskGradientLayer.locations = [0.84]
        view.layer.mask = maskGradientLayer

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private lazy var topHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private lazy var bottomHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var toolsViewsConstraints: [ViewConstraints] = []
    private var activeToolViewIndex: Int!
    private var activeToolView: ToolView {
        return toolViews[activeToolViewIndex]
    }
    public var activeTool: Tool {
        return toolViews[activeToolViewIndex].tool
    }
    private var isActiveToolCenteralTool: Bool {
        let toolViewsCount = toolViews.count
        
        if toolViewsCount % 2 == 0 {
            return false
        } else if toolViews[Int(ceil(Float(toolViewsCount) / Float(2)))] === toolViews[activeToolViewIndex] {
            return true
        } else {
            return false
        }
    }
    
    public var delegate: CanvasToolBarViewDelegate?
    
    public var doneButtonPressedAction: (() -> Void)?
    public var cancelButtonPressedAction: (() -> Void)?
    
    private var isEditing: Bool = false
    
    // MARK: Initialization
    
    public init() {
        super.init(frame: .zero)

        activeToolViewIndex = 0
        
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
        
        toolViewsWrapper.layer.mask?.frame = toolViewsWrapper.bounds
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let toolViewsWrapperPoint = toolViewsWrapper.convert(point, from: self)
        if toolViewsWrapper.point(inside: toolViewsWrapperPoint, with: event) {
            for toolView in toolViews {
                let toolViewPoint = toolView.convert(point, from: self)
                if toolView.point(inside: toolViewPoint, with: event) {
                    return toolView
                }
            }
        }
        
        let colorPickerPoint = colorPickerButton.convert(point, from: self)
        if colorPickerButton.point(inside: colorPickerPoint, with: event) {
            return colorPickerButton
        }
        
        return super.hitTest(point, with: event)
    }
    
    // MARK: Actions
    
    @objc private func addButtonPressed() {
    }
    
    @objc private func doneButtonPressed() {
        doneButtonPressedAction?()
    }
    
    @objc private func cancelButtonPressed() {
        cancelButtonPressedAction?()
    }
    
    @objc private func toolSelected(_ sender: UITapGestureRecognizer) {
        let toolView = sender.view as! ToolView
        let newActiveToolViewIndex = toolViews.firstIndex(of: toolView)!
        
        if activeToolViewIndex == newActiveToolViewIndex {
            if toolView.tool.type.haveWidth {
                toggleEditingState()
            }
        } else {
            changeActiveTool(to: newActiveToolViewIndex)
        }
    }
    
    @objc private func sliderValueChanged(_ sender: Slider) {
        changeActiveToolWidth(to: slider.value)
    }
    
    // MARK: Private Functions
    
    private func buildViewHierarchy() {
        addSubview(toolViewsWrapper)
        toolViews.forEach { toolViewsWrapper.addSubview($0) }
        
        addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(topHorizontalStackView)
        verticalStackView.addArrangedSubview(bottomHorizontalStackView)
        
        topHorizontalStackView.addArrangedSubview(colorPickerButton)
        topHorizontalStackView.addArrangedSubview(addButton)
        
        bottomHorizontalStackView.addArrangedSubview(cancelButton)
        bottomHorizontalStackView.addArrangedSubview(segmentedControl)
        bottomHorizontalStackView.addArrangedSubview(slider)
        bottomHorizontalStackView.addArrangedSubview(doneButton)
    }
    
    private func setupConstraints() {
        let toolHorizontalPadding: CGFloat = (Constants.toolViewsWidth / CGFloat(toolViews.count) - Constants.regularToolViewWidth) / 2
        toolViews.enumerated().forEach { index, toolView in
            let totalPadding =  CGFloat(2 * index + 1) * toolHorizontalPadding
            let leftOffset =  totalPadding + CGFloat(index) * Constants.regularToolViewWidth
            let bottomOffset = (index == activeToolViewIndex) ? 0 : Constants.regularToolViewBottomOffset
            
            var toolViewConstraints = ViewConstraints()
            toolViewConstraints.left = toolView.leftAnchor.constraint(equalTo: toolViewsWrapper.leftAnchor, constant: leftOffset)
            toolViewConstraints.bottom = toolView.bottomAnchor.constraint(equalTo: toolViewsWrapper.bottomAnchor, constant: bottomOffset)
            toolViewConstraints.height = toolView.heightAnchor.constraint(equalToConstant: Constants.regularToolViewHeight)
            toolViewConstraints.width = toolView.widthAnchor.constraint(equalToConstant: 20)
            
            NSLayoutConstraint.activate([
                toolViewConstraints.bottom!,
                toolViewConstraints.left!,
                toolViewConstraints.height!,
                toolViewConstraints.width!,
            ])
            
            toolsViewsConstraints.append(toolViewConstraints)
        }
        
        NSLayoutConstraint.activate([
            toolViewsWrapper.bottomAnchor.constraint(equalTo: bottomHorizontalStackView.topAnchor),
            toolViewsWrapper.centerXAnchor.constraint(equalTo: centerXAnchor),
            toolViewsWrapper.heightAnchor.constraint(equalToConstant: Constants.bigToolViewHeight),
            toolViewsWrapper.widthAnchor.constraint(equalToConstant: Constants.toolViewsWidth),
        ])
        
        NSLayoutConstraint.activate([
            colorPickerButton.heightAnchor.constraint(equalToConstant: 33),
            colorPickerButton.widthAnchor.constraint(equalTo: colorPickerButton.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            addButton.heightAnchor.constraint(equalToConstant: 33),
            addButton.widthAnchor.constraint(equalTo: addButton.heightAnchor),
        ])
        
        NSLayoutConstraint.activate([
            segmentedControl.heightAnchor.constraint(equalToConstant: 33),
            segmentedControl.widthAnchor.constraint(equalToConstant: 276),
        ])
        
        NSLayoutConstraint.activate([
            slider.heightAnchor.constraint(equalToConstant: 28),
            slider.widthAnchor.constraint(equalToConstant: 240),
        ])
        
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalToConstant: 33),
            doneButton.widthAnchor.constraint(equalTo: doneButton.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            cancelButton.heightAnchor.constraint(equalToConstant: 33),
            cancelButton.widthAnchor.constraint(equalTo: cancelButton.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            verticalStackView.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            verticalStackView.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
        ])
    }
    
    private func configureViews() {
    }
    
    private func toggleEditingState() {
        if !isEditing {
            centerActiveTool()
            
            slider.value = activeTool.width
            
            segmentedControl.isHidden = true
            slider.isHidden = false
            
            isEditing = true
        } else {
            uncenterActiveTool()
            
            segmentedControl.isHidden = false
            slider.isHidden = true
            
            isEditing = false
        }
    }
    
    private func changeActiveTool(to index: Int) {
        let activeToolViewBottomConstraint = toolsViewsConstraints[activeToolViewIndex].bottom!
        let newActiveToolViewBottomConstraint = toolsViewsConstraints[index].bottom!
        
        UIView.animate(withDuration: Constants.toolSelectionAnimationDuration, delay: 0, options: .curveEaseInOut) { [weak self] in
            activeToolViewBottomConstraint.constant = Constants.regularToolViewBottomOffset
            newActiveToolViewBottomConstraint.constant = 0
            self?.layoutIfNeeded()
        }
        
        activeToolViewIndex = index
        colorPickerButton.selectedColor = activeTool.color
        delegate?.canvasToolBarViewActiveToolChanged(self)
    }
    
    private func centerActiveTool() {
        let toolViewsCount = toolViews.count
        
        if isActiveToolCenteralTool {
            
        } else {
            let activeToolViewConstraints = toolsViewsConstraints[activeToolViewIndex]
            let toolAreaWidth = Constants.toolViewsWidth / CGFloat(toolViewsCount)
            let currentLeftOffset = activeToolViewConstraints.left!.constant
            let additionalOffset = Constants.toolViewsWidth / 2 - currentLeftOffset - toolAreaWidth / 2
            
            activeToolViewConstraints.left!.constant = currentLeftOffset + additionalOffset
            activeToolViewConstraints.height!.constant = Constants.bigToolViewHeight
            activeToolViewConstraints.width!.constant = Constants.bigToolViewWidth
            toolViews.enumerated().forEach { index, toolView in
                guard index != activeToolViewIndex else { return }
                
                let toolViewConstants = toolsViewsConstraints[index]
                
                let currentToolLeftOffset = toolViewConstants.left!.constant
                toolViewConstants.left!.constant = currentToolLeftOffset + additionalOffset
                toolViewConstants.bottom!.constant = Constants.regularToolViewHeight
            }
            
            UIView.animate(
                withDuration: Constants.toolCenteringAnimationDuration,
                delay: 0
            ) { [weak self] in
                self?.toolViewsWrapper.layoutIfNeeded()
            }
        }
    }
    
    private func uncenterActiveTool() {
        if isActiveToolCenteralTool {
            
        } else {
            let toolHorizontalPadding: CGFloat = (Constants.toolViewsWidth / CGFloat(toolViews.count) - Constants.regularToolViewWidth) / 2
            
            toolViews.enumerated().forEach { index, toolView in
                let toolViewConstraints = toolsViewsConstraints[index]
                
                let totalPadding =  CGFloat(2 * index + 1) * toolHorizontalPadding
                let leftOffset =  totalPadding + CGFloat(index) * Constants.regularToolViewWidth
                
                toolViewConstraints.left!.constant = leftOffset
                
                if index == activeToolViewIndex {
                    toolViewConstraints.height!.constant = Constants.regularToolViewHeight
                    toolViewConstraints.width!.constant = Constants.regularToolViewWidth
                } else {
                    toolViewConstraints.bottom!.constant = Constants.regularToolViewBottomOffset
                }
            }
            
            UIView.animate(
                withDuration: Constants.toolCenteringAnimationDuration,
                delay: 0
            ) { [weak self] in
                self?.toolViewsWrapper.layoutIfNeeded()
            }
        }
    }
    
    private func changeActiveToolColor(to color: CGColor) {
        toolViews[activeToolViewIndex].setColor(to: color)
        delegate?.canvasToolBarViewActiveToolChanged(self)
    }
    
    private func changeActiveToolWidth(to width: CGFloat) {
        toolViews[activeToolViewIndex].setWidth(to: width, minWidth: slider.minimumValue, maxWidth: slider.maximumValue)
        delegate?.canvasToolBarViewActiveToolChanged(self)
    }
}

// MARK: - : ColorPickerDelegate

extension CanvasToolBarView: ColorPickerButtonDelegate {
    func colorChanged(_ colorPicker: ColorPickerButton) {
        let color = colorPicker.selectedColor
        changeActiveToolColor(to: color)
    }
}
