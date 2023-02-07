import UIKit

extension CGColor {
    var red: CGFloat {
        let ciColor = CIColor(cgColor: self)
        return ciColor.red
    }
    
    var green: CGFloat {
        let ciColor = CIColor(cgColor: self)
        return ciColor.green
    }
    
    var blue: CGFloat {
        let ciColor = CIColor(cgColor: self)
        return ciColor.blue
    }
    
    var alpha: CGFloat {
        let ciColor = CIColor(cgColor: self)
        return ciColor.alpha
    }
}
