import UIKit

enum Tool {
    case pen(width: CGFloat = 5, color: CGColor = UIColor.red.cgColor)
    case brush(width: CGFloat = 5, color: CGColor = UIColor.green.cgColor)
    case neon(width: CGFloat = 5, color: CGColor = UIColor.blue.cgColor)
    case pencil(width: CGFloat = 5, color: CGColor = UIColor.white.cgColor)
    case eraser(width: CGFloat = 5)
    case objectEraser(width: CGFloat = 5)
    case blurEraser(width: CGFloat = 5)
    case lasso
    
    public var view: UIView {
        let view = UIView()
        
        let tipImageView = tipImageView
        let baseImageView = baseImageView
    
        view.addSubview(baseImageView)
        baseImageView.frame = view.bounds
        baseImageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        guard let tipImageView = tipImageView else { return view }
        view.addSubview(tipImageView)
        tipImageView.frame = view.bounds
        tipImageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.tintColor = UIColor(cgColor: color!)
        
        return view
    }
    
    private var tipImageName: String? {
        switch self {
        case .pen:
            return "Tip/pen"
        case .pencil:
            return "Tip/pencil"
        case .brush:
            return "Tip/brush"
        case .neon:
            return "Tip/neon"
        default:
            return nil
        }
    }
    
    public var tipImageView: UIImageView? {
        guard let tipImageName = tipImageName else { return nil }
        let tipImage = UIImage(named: tipImageName)!.withRenderingMode(.alwaysTemplate)

        let tipImageView = UIImageView(image: tipImage)
        tipImageView.contentMode = .scaleAspectFit
        
        return tipImageView
    }
    
    private var baseImageName: String {
        switch self {
        case .pen:
            return "Base/pen"
        case .pencil:
            return "Base/pencil"
        case .brush:
            return "Base/brush"
        case .neon:
            return "Base/neon"
        case .eraser:
            return "Base/eraser"
        case .objectEraser:
            return "Base/objectEraser"
        case .blurEraser:
            return "Base/blurEraser"
        case .lasso:
            return "Base/lasso"
        }
    }
    
    public var baseImageView: UIImageView {
        let baseImage = UIImage(named: baseImageName)!
        
        let baseImageView = UIImageView(image: baseImage)
        baseImageView.contentMode = .scaleAspectFit
        
        return baseImageView
    }
    
    var width: CGFloat? {
        get {
            switch self {
            case .pen(let width, _):
                return width
            case .brush(let width, _):
                return width
            case .neon(let width, _):
                return width
            case .pencil(let width, _):
                return width
            case .eraser(let width):
                return width
            case .objectEraser(let width):
                return width
            case .blurEraser(let width):
                return width
            case .lasso:
                return nil
            }
        }
        
        set(width) {
            guard let width = width else { return }
            
            switch self {
            case .pen(width: _, color: let color):
                self = .pen(width: width, color: color)
            case .brush(width: _, color: let color):
                self = .brush(width: width, color: color)
            case .neon(width: _, color: let color):
                self = .neon(width: width, color: color)
            case .pencil(width: _, color: let color):
                self = .pencil(width: width, color: color)
            case .eraser(width: _):
                self = .eraser(width: width)
            case .objectEraser(width: _):
                self = .objectEraser(width: width)
            case .blurEraser(width: _):
                self = .blurEraser(width: width)
            default:
                break
            }
        }
    }
    
    var color: CGColor? {
        get {
            switch self {
            case .pen(_, let color):
                return color
            case .brush(_, let color):
                return color
            case .neon(_, let color):
                return color
            case .pencil(_, let color):
                return color
            default:
                return nil
            }
        }
        
        set(color) {
            guard let color = color else { return }
            
            switch self {
            case .pen(width: let width, color: _):
                self = .pen(width: width, color: color)
            case .brush(width: let width, color: _):
                self = .brush(width: width, color: color)
            case .neon(width: let width, color: _):
                self = .neon(width: width, color: color)
            case .pencil(width:let  width, color: _):
                self = .pencil(width: width, color: color)
            default:
                break
            }
        }
    }
    
    var haveWidthIndicator: Bool {
        switch self {
        case .pen, .brush, .neon, .pencil:
            return true
        default:
            return false
        }
    }
}
