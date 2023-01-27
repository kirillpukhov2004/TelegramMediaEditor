import CoreGraphics

extension CGFloat {
    static func *<T: BinaryInteger>(lhs: CGFloat, rhs: T) -> CGFloat {
        return lhs * CGFloat(rhs)
    }
    
    static func *<T: BinaryInteger>(lhs: T, rhs: CGFloat) -> CGFloat {
        return CGFloat(lhs) * rhs
    }
}
