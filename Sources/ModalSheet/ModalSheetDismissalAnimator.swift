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
        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController = transitionContext.viewController(forKey: .to),
              let presentationController = fromViewController.presentationController as? ModalSheetPresentationController,
              let fromView = transitionContext.view(forKey: .from) else {
                  return transitionContext.completeTransition(false)
              }
        
        toViewController.beginAppearanceTransition(true, animated: true)
        
        let containerView = transitionContext.containerView
        let animationProgress: CGFloat = 0.0 // dismissed progress
        let animation = presentationController.animation(for: animationProgress, in: containerView)
        animator.addAnimations {
            fromView.parentDropShadowView?.transform = animation.transform
            presentationController.dimmingView.alpha = animation.alpha
        }
      
        animator.addCompletion { position in
            if position == UIViewAnimatingPosition.end {
                fromView.removeFromSuperview()
                toViewController.endAppearanceTransition()
                let didComplete = !transitionContext.transitionWasCancelled
                transitionContext.completeTransition(didComplete)
            }
        }
        animator.startAnimation()
    }
}
