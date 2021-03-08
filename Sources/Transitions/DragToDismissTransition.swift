import UIKit

class DragToDismissTransition: UIPercentDrivenInteractiveTransition {
    unowned var transitioningController: UIViewController

    init(transitioningController: UIViewController) {
        self.transitioningController = transitioningController
        super.init()

        let edge = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        transitioningController.view.addGestureRecognizer(edge)
    }

    @objc func didPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: transitioningController.view)
        let percent = (translation.x / transitioningController.view.bounds.size.width) * 0.5

        switch gesture.state {
        case .began:
            transitioningController.dismiss(animated: true)
        case .changed:
            update(percent)
        case .ended, .cancelled:
            if percent >= 0.5 {
                finish()
            } else {
                cancel()
            }
        default:
            break
        }
    }
}
