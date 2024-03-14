import UIKit

public class ModalSheetDismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    public let animator: UIViewPropertyAnimator

    override public init() {
        let springTimingParameters = UISpringTimingParameters(damping: 1.0, response: 0.3)
        self.animator = UIViewPropertyAnimator(duration: 0.0, timingParameters: springTimingParameters)
        super.init()
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animator.duration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
              let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController = transitionContext.viewController(forKey: .to),
              let presentationController = fromViewController.presentationController as? ModalSheetPresentationController else {
            return transitionContext.completeTransition(false)
        }

        let containerView = transitionContext.containerView
        let transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)

        animator.addAnimations {
            fromView.parentDropShadowView?.transform = transform
            presentationController.dimmingView.alpha = 0
        }

        animator.addCompletion { position in
            switch position {
            case .start:
                toViewController.beginAppearanceTransition(true, animated: true)
            case .current:
                break
            case .end:
                fromView.removeFromSuperview()
                toViewController.endAppearanceTransition()
                let didComplete = !transitionContext.transitionWasCancelled
                transitionContext.completeTransition(didComplete)
            @unknown default:
                break
            }
        }
        animator.startAnimation()
    }
}
