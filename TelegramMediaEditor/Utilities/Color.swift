import UIKit

struct Color: Codable {
    public var red: Double = 0
    public var green: Double = 0
    public var blue: Double = 0
    public var alpha: Double = 1
    
    public init(cgColor: CGColor) {
        var components: [CGFloat] = [0, 0, 0, 1]
        
        let numberOfComponents = cgColor.numberOfComponents
        for index in 0..<numberOfComponents {
            switch index {
            case 0:
                components[0] = cgColor.components?[index] ?? 0
            case 1:
                components[1] = cgColor.components?[index] ?? 0
            case 2:
                components[2] = cgColor.components?[index] ?? 0
            case 3:
                components[3] = cgColor.components?[index] ?? 1
            default:
                return
            }
        }
        
        self.red = components[0]
        self.green = components[1]
        self.blue = components[2]
        self.alpha = components[3]
    }
    
    public var cgColor: CGColor {
        return CGColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
