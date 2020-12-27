import UIKit

class BouncyAnimation: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
    private let operation: UINavigationController.Operation

    init(operation: UINavigationController.Operation) {
        self.operation = operation
    }

    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if operation == .pop {
            animatePop(using: transitionContext)
            return
        }

        let from = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let to = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!

        let final = transitionContext.finalFrame(for: to)

        let start = final.offsetBy(dx: final.width, dy: 0)
        to.view.frame = start

        transitionContext.containerView.insertSubview(to.view, aboveSubview: from.view)

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut,
            animations: {
                to.view.frame = final
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }

    func animatePop(using transitionContext: UIViewControllerContextTransitioning) {
        let from = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let to = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!

        let initial = transitionContext.initialFrame(for: from)
        let fromFinal = initial.offsetBy(dx: initial.width, dy: 0)

        let start = initial.offsetBy(dx: -initial.width, dy: 0)
        to.view.frame = start

        let final = transitionContext.finalFrame(for: to)

        transitionContext.containerView.insertSubview(to.view, belowSubview: from.view)

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut,
            animations: {
                to.view.frame = final
                from.view.frame = fromFinal
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}
