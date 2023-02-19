import UIKit

extension UIColor {
    static let lightGray = UIColor(red: 93/255, green: 93/255, blue: 93/255, alpha: 1.0)
    static let darkGray = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1.0)
    
    func withMultipliedBrightnessBy(_ factor: CGFloat) -> UIColor {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return UIColor(hue: hue, saturation: saturation, brightness: max(0.0, min(1.0, brightness * factor)), alpha: alpha)
    }
}

extension UIColor {
    public convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
