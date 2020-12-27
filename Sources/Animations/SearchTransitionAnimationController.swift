import UIKit

class SearchTransitionAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2.0
    }

    func animateTransition(using _: UIViewControllerContextTransitioning) {}
}

class SimpleOver: NSObject, UIViewControllerAnimatedTransitioning {
    var popStyle: Bool = false

    func transitionDuration(
        using _: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return 0.2
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if popStyle {
            animatePop(using: transitionContext)
            return
        }

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

    func animatePop(using transitionContext: UIViewControllerContextTransitioning) {
        let fz = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let tz = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!

        let f = transitionContext.initialFrame(for: fz)
        let fOffPop = f.offsetBy(dx: f.width, dy: 0)

        transitionContext.containerView.insertSubview(tz.view, belowSubview: fz.view)

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 5,
            animations: {
                fz.view.frame = fOffPop
            }, completion: { _ in
                transitionContext.completeTransition(true)
            }
        )
    }
}
