import UIKit

enum UIViewEdge: Equatable {
    case top(margin: CGFloat)
    case bottom(margin: CGFloat)
    case leading(margin: CGFloat)
    case trailing(margin: CGFloat)
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    func autoPinEdgesToSuperview(margin: CGFloat = 0) {
        autoPinToSuperview(edges: [
            .top(margin: margin),
            .bottom(margin: margin),
            .leading(margin: margin),
            .trailing(margin: margin),
        ])
    }

    func autoPinToSuperview(edges: [UIViewEdge]) {
        guard let superview = superview else {
            NSLog("No superview set")
            abort()
        }
        var constraints: [NSLayoutConstraint] = []
        for edge in edges {
            switch edge {
            case let .top(margin):
                constraints.append(
                    superview.topAnchor.constraint(equalTo: topAnchor, constant: -margin)
                )
            case let .bottom(margin):
                constraints.append(
                    superview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: margin)
                )
            case let .leading(margin):
                constraints.append(
                    superview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -margin)
                )
            case let .trailing(margin):
                constraints.append(
                    superview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: margin)
                )
            }
        }

        NSLayoutConstraint.activate(constraints)
        superview.setNeedsLayout()
    }
}
