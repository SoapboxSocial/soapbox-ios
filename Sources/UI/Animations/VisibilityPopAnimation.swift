import UIKit

class VisibilityPopAnimation {
    static func show(_ view: UIView) {
        if !view.isHidden {
            return
        }

        view.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
        view.isHidden = false

        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 3,
            options: [.curveEaseInOut],
            animations: {
                view.transform = .identity
            }
        )
    }

    static func hide(_ view: UIView) {
        if view.isHidden {
            return
        }

        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 3,
            options: [.curveEaseInOut],
            animations: {
                view.transform = CGAffineTransform.identity.scaledBy(x: 0.0001, y: 0.0001)
            },
            completion: { _ in
                view.isHidden = true
                view.transform = .identity
            }
        )
    }
}
