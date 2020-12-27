import UIKit

class BouncyAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fz = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let tz = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!

        let f = transitionContext.finalFrame(for: tz)

        let fOff = f.offsetBy(dx: f.width, dy: 0)
        tz.view.frame = fOff

        transitionContext.containerView.insertSubview(tz.view, aboveSubview: fz.view)

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 3,
            options: .curveEaseInOut,
            animations: {
                tz.view.frame = f
            }, completion: { _ in
                transitionContext.completeTransition(true)
            }
        )
    }
}
