import UIKit

fileprivate enum Constants {
    static let toolViewsHeight: CGFloat = 88
    static let toolViewsWidth: CGFloat = 240
    
    static let regularToolViewHeight: CGFloat = 72
    static let regularToolViewWidth: CGFloat = 20
    
    static let activeToolViewHeight: CGFloat = 88
    
    static let bigToolViewHeight: CGFloat = 120
    static let bigToolViewWidth: CGFloat = 40
}

fileprivate struct ToolViewConstraints {
    var top: NSLayoutConstraint?
    var right: NSLayoutConstraint?
    var bottom: NSLayoutConstraint?
    var left: NSLayoutConstraint?
    var y: NSLayoutConstraint?
    var x: NSLayoutConstraint?
    var height: NSLayoutConstraint?
    var width: NSLayoutConstraint?
}

class ToolBarView: UIView {
    private lazy var toolViews: [ToolView] = {
        let toolsTypesList: [ToolType] = [.pen, .brush, .neon, .pencil, .eraser, .lasso]
        
        var toolsViews = [ToolView]()
        toolsViews = toolsTypesList.map { toolType in
            let tool = Tool(type: toolType, width: 1, color: .white)
            let toolView = ToolView(for: tool)
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toolTapped(_:)))
            toolView.addGestureRecognizer(tapGestureRecognizer)
            toolView.translatesAutoresizingMaskIntoConstraints = false
            return toolView
        }
        return toolsViews
    }()
    private lazy var colorPicker: ColorPicker = {
        let colorPicker = ColorPicker()
        colorPicker.translatesAutoresizingMaskIntoConstraints = false
        return colorPicker
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
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private lazy var toolViewsWrapper: UIView = {
        let view = UIView()
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
    
    private var activeToolViewIndex: Int!
    private var toolsViewsConstaints: [ToolViewConstraints] = []
    public var doneButtonPressedAction: (() -> Void)?
    public var cancelButtonPressedAction: (() -> Void)?
    
    public var activeTool: Tool {
        return toolViews[activeToolViewIndex].tool
    }
    private var isEditing: Bool = false
    
    public init() {
        super.init(frame: .zero)

        buildViewHierarchy()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildViewHierarchy() {
        toolViews.forEach { toolView in
            toolViewsWrapper.addSubview(toolView)
        }
        addSubview(toolViewsWrapper)
        
        verticalStackView.addArrangedSubview(topHorizontalStackView)
        verticalStackView.addArrangedSubview(bottomHorizontalStackView)
        
        topHorizontalStackView.addArrangedSubview(colorPicker)
        topHorizontalStackView.addArrangedSubview(addButton)
        
        bottomHorizontalStackView.addArrangedSubview(cancelButton)
        bottomHorizontalStackView.addArrangedSubview(segmentedControl)
        bottomHorizontalStackView.addArrangedSubview(slider)
        bottomHorizontalStackView.addArrangedSubview(doneButton)
        addSubview(verticalStackView)
    }
    
    private func setupConstraints() {
        activeToolViewIndex = 0
        
        let toolHorizontalPadding: CGFloat = (Constants.toolViewsWidth / CGFloat(toolViews.count) - Constants.regularToolViewWidth) / 2
        toolViews.enumerated().forEach { index, toolView in
            var toolViewConstraints = ToolViewConstraints()
            
            let totalPadding =  CGFloat(2 * index + 1) * toolHorizontalPadding
            let leftOffset =  totalPadding + CGFloat(index) * Constants.regularToolViewWidth
            toolViewConstraints.left = toolView.leftAnchor.constraint(
                equalTo: toolViewsWrapper.leftAnchor,
                constant: leftOffset
            )
            toolViewConstraints.bottom = toolView.bottomAnchor.constraint(equalTo: toolViewsWrapper.bottomAnchor)
            
            if index == activeToolViewIndex {
                toolViewConstraints.height = toolView.heightAnchor.constraint(equalToConstant: Constants.activeToolViewHeight)
            } else {
                toolViewConstraints.height = toolView.heightAnchor.constraint(equalToConstant: Constants.regularToolViewHeight)
            }
            toolViewConstraints.width = toolView.widthAnchor.constraint(equalToConstant: 20)
            
            NSLayoutConstraint.activate([
                toolViewConstraints.bottom!,
                toolViewConstraints.left!,
                toolViewConstraints.height!,
                toolViewConstraints.width!,
            ])
            
            toolsViewsConstaints.append(toolViewConstraints)
        }
        
        NSLayoutConstraint.activate([
            toolViewsWrapper.bottomAnchor.constraint(equalTo: bottomHorizontalStackView.topAnchor),
            toolViewsWrapper.centerXAnchor.constraint(equalTo: centerXAnchor),
            toolViewsWrapper.heightAnchor.constraint(equalToConstant: Constants.toolViewsHeight),
            toolViewsWrapper.widthAnchor.constraint(equalToConstant: Constants.toolViewsWidth),
        ])
        
        NSLayoutConstraint.activate([
            colorPicker.heightAnchor.constraint(equalToConstant: 33),
            colorPicker.widthAnchor.constraint(equalTo: colorPicker.heightAnchor)
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
            verticalStackView.rightAnchor.constraint(equalTo: rightAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            verticalStackView.leftAnchor.constraint(equalTo: leftAnchor),
        ])
    }
    
    @objc private func addButtonPressed() {
    }
    
    @objc private func doneButtonPressed() {
        doneButtonPressedAction?()
    }
    
    @objc private func cancelButtonPressed() {
        cancelButtonPressedAction?()
    }
    
    @objc private func toolTapped(_ sender: UITapGestureRecognizer) {
        let toolView = sender.view as! ToolView
        guard let tappedToolViewIndex = toolViews.firstIndex(of: toolView) else {
            fatalError("\(#function): Selected tool isn't in the view stack")
        }
        tapToolAction(index: tappedToolViewIndex)
    }
    
    private func tapToolAction(index newActiveToolViewIndex: Int) {
        if activeToolViewIndex == newActiveToolViewIndex {
            if !isEditing {
                centerActiveTool()
            } else {
                uncenterActiveTool()
            }
        } else {
            let activeToolViewHeightConstraint = toolsViewsConstaints[activeToolViewIndex].height!
            let newActiveToolViewHeightConstraint = toolsViewsConstaints[newActiveToolViewIndex].height!
            UIView.animate(
                withDuration: 0.15,
                delay: 0,
                options: .curveEaseIn
            ) { [weak self] in
                activeToolViewHeightConstraint.constant = Constants.regularToolViewHeight
                newActiveToolViewHeightConstraint.constant = Constants.activeToolViewHeight
                self?.layoutIfNeeded()
            }
            
            self.activeToolViewIndex = newActiveToolViewIndex
        }
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
    
    private func centerActiveTool() {
        let toolViewsCount = toolViews.count
        let animationDuration: CGFloat = 1
        
        if isActiveToolCenteralTool {
            
        } else {
            let activeToolViewConstraints = toolsViewsConstaints[activeToolViewIndex]
            let toolAreaWidth = Constants.toolViewsWidth / CGFloat(toolViewsCount)
            let currentLeftOffset = activeToolViewConstraints.left!.constant
            let additionalOffset = Constants.toolViewsWidth / 2 - currentLeftOffset - toolAreaWidth / 2
            
            activeToolViewConstraints.left!.constant = currentLeftOffset + additionalOffset
            activeToolViewConstraints.height!.constant = Constants.bigToolViewHeight
            activeToolViewConstraints.width!.constant = Constants.bigToolViewWidth
            toolViews.enumerated().forEach { index, toolView in
                guard index != activeToolViewIndex else { return }
                
                let toolViewConstants = toolsViewsConstaints[index]
                
                let currentToolLeftOffset = toolViewConstants.left!.constant
                toolViewConstants.left!.constant = currentToolLeftOffset + additionalOffset
                toolViewConstants.bottom!.constant = Constants.regularToolViewHeight
            }
            
            UIView.animate(
                withDuration: animationDuration,
                delay: 0
            ) { [weak self] in
                self?.toolViewsWrapper.layoutIfNeeded()
            }
            
            isEditing = true
        }
    }
    
    private func uncenterActiveTool() {
        let animationDuration: CGFloat = 1
        
        if isActiveToolCenteralTool {
            
        } else {
            let toolHorizontalPadding: CGFloat = (Constants.toolViewsWidth / CGFloat(toolViews.count) - Constants.regularToolViewWidth) / 2
            
            toolViews.enumerated().forEach { index, toolView in
                let toolViewConstraints = toolsViewsConstaints[index]
                
                let totalPadding =  CGFloat(2 * index + 1) * toolHorizontalPadding
                let leftOffset =  totalPadding + CGFloat(index) * Constants.regularToolViewWidth
                
                toolViewConstraints.left!.constant = leftOffset
                
                if index == activeToolViewIndex {
                    toolViewConstraints.height!.constant = Constants.activeToolViewHeight
                    toolViewConstraints.width!.constant = Constants.regularToolViewWidth
                } else {
                    toolViewConstraints.bottom!.constant -= Constants.regularToolViewHeight
                }
            }
            
            UIView.animate(
                withDuration: animationDuration,
                delay: 0
            ) { [weak self] in
                self?.toolViewsWrapper.layoutIfNeeded()
            }
            
            isEditing = false
        }
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
        
        return super.hitTest(point, with: event)
    }
}
