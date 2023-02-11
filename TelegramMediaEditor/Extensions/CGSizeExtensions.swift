import CoreGraphics

extension CGSize {
    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs,
                      height: lhs.height * rhs)
    }
    
    static func *= (lhs: inout CGSize, rhs: CGFloat) {
        lhs.height *= rhs
        lhs.width *= rhs
    }
}
