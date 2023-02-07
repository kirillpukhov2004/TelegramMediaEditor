import UIKit

struct Color: Codable {
    public var red: Double = 0
    public var green: Double = 0
    public var blue: Double = 0
    public var alpha: Double = 1
    
    public init(cgColor: CGColor) {
        self.red = cgColor.red
        self.green = cgColor.green
        self.blue = cgColor.blue
        self.alpha = cgColor.alpha
    }
    
    public var cgColor: CGColor {
        return CGColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
