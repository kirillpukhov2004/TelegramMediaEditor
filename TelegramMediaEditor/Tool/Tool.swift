import UIKit

class Tool {
    public var type: ToolType
    
    public var width: CGFloat
    public var color: CGColor
    
    public init(type: ToolType, width: CGFloat, color: CGColor) {
        self.type = type
        self.width = width
        self.color = color
    }
}
