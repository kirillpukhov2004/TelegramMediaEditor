import UIKit

enum ToolType: Int {
    case pen
    case brush
    case neon
    case pencil
    case eraser
    case objectEraser
    case blurEraser
    case lasso
    
    var baseImage: UIImage {
        switch self {
        case .pen:
            return UIImage(named: "Base/pen")!
        case .pencil:
            return UIImage(named: "Base/pencil")!
        case .brush:
            return UIImage(named: "Base/brush")!
        case .neon:
            return UIImage(named: "Base/neon")!
        case .eraser:
            return UIImage(named: "Base/eraser")!
        case .objectEraser:
            return UIImage(named: "Base/objectEraser")!
        case .blurEraser:
            return UIImage(named: "Base/blurEraser")!
        case .lasso:
            return UIImage(named: "Base/lasso")!
        }
    }
    
    var tipImage: UIImage? {
        switch self {
        case .pen:
            return UIImage(named: "Tip/pen")!
        case .pencil:
            return UIImage(named: "Tip/pencil")!
        case .brush:
            return UIImage(named: "Tip/brush")!
        case .neon:
            return UIImage(named: "Tip/neon")!
        default:
            return nil
        }
    }
    
    var haveWidth: Bool {
        switch self {
        case .pen:
            return true
        case .brush:
            return true
        case .neon:
            return true
        case .pencil:
            return true
        default:
            return false
        }
    }
}
