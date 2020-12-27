import UIKit

class PanTransition: UIPercentDrivenInteractiveTransition {
    private(set) var usingGestures = false

    unowned var transitioningController: UIViewController

    init(transitioningController: UIViewController) {
        self.transitioningController = transitioningController
    }

    func didPan(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: transitioningController.view)
        let percent = (translation.x / UIScreen.main.bounds.size.width) * 0.5

        switch gesture.state {
        case .began:
            usingGestures = true
            transitioningController.navigationController?.popViewController(animated: true)
        case .changed:
            update(percent)
        case .ended, .cancelled:
            usingGestures = false

            if percent > 0.2 { // @TODO INVESTIGATE
                finish()
            } else {
                cancel()
            }
        default:
            break
        }
    }
}
