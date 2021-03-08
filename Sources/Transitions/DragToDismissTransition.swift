import UIKit

class DragToDismissTransition: UIPercentDrivenInteractiveTransition {
    private(set) var usingGestures = false

    unowned var transitioningController: UIViewController

    init(transitioningController: UIViewController) {
        self.transitioningController = transitioningController
        super.init()

        let edge = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        transitioningController.view.addGestureRecognizer(edge)
    }

    @objc func didPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: transitioningController.view)
        let verticalMovement = translation.y / transitioningController.view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)

        switch gesture.state {
        case .began:
            usingGestures = true
            transitioningController.dismiss(animated: true)
        case .changed:
            update(progress)
        case .ended, .cancelled:
            usingGestures = false

            if progress >= 0.3 {
                finish()
            } else {
                cancel()
            }
        default:
            break
        }
    }
}
