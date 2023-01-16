import UIKit

extension CGSize {
    static func * (left: CGSize, right: CGFloat) -> CGSize {
        return CGSize(width: left.width * right,
                      height: left.height * right)
    }
}
