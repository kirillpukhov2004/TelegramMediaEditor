import UIKit

extension UIBezierPath {
    convenience init(roundedRect rect: CGRect,
                     topLeftRadius r1: CGFloat = 0,
                     topRightRadius r2: CGFloat = 0,
                     bottomRightRadius r3: CGFloat = 0,
                     bottomLeftRadius r4: CGFloat = 0) {
        let up: CGFloat = 1.5 * .pi
        let right: CGFloat = 2 * .pi
        let down: CGFloat = 0.5 * .pi
        let left: CGFloat  = .pi
        self.init()
        addArc(withCenter: CGPoint(x: rect.minX + r1, y: rect.minY + r1), radius: r1, startAngle: left,  endAngle: up,    clockwise: true)
        addArc(withCenter: CGPoint(x: rect.maxX - r2, y: rect.minY + r2), radius: r2, startAngle: up,    endAngle: right, clockwise: true)
        addArc(withCenter: CGPoint(x: rect.maxX - r3, y: rect.maxY - r3), radius: r3, startAngle: right, endAngle: down,  clockwise: true)
        addArc(withCenter: CGPoint(x: rect.minX + r4, y: rect.maxY - r4), radius: r4, startAngle: down,  endAngle: left,  clockwise: true)
        close()
    }
}
