import UIKit

public class ModalSheetPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    public let detents: [Detent]
    public let selectedDetent: Detent?
    public let animator: UIViewPropertyAnimator
    
    public init(detents: [Detent], selectedDetent: Detent?) {
        self.detents = detents
        self.selectedDetent = selectedDetent
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
              let presentationView = transitionContext.view(forKey: .to),
              let presentationController = toViewController.presentationController as? ModalSheetPresentationController else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView
        var initialFrame = transitionContext.initialFrame(for: fromViewController)
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        
        var detent: Detent = .large
        if let selectedDetent = self.selectedDetent, detents.contains(selectedDetent) {
            detent = selectedDetent
        } else if detents.contains(.medium) {
            detent = .medium
        }
        
        presentationView.frame = finalFrame
        presentationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let dropShadowView = DropShadowView()
        dropShadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dropShadowView.frame = finalFrame
        
        let contentView = UIView()
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = finalFrame
        contentView.addSubview(presentationView)

        contentView.clipsToBounds = true
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.layer.cornerRadius = presentationController.preferredCornerRadius ?? 8.0
        dropShadowView.addSubview(contentView)
        
        let preferredContentSize = presentationController.preferredContentSize(for: detent)
        initialFrame.size.width = preferredContentSize.width
        dropShadowView.transform = CGAffineTransform(translationX: 0, y: initialFrame.height)
 
        containerView.addSubview(dropShadowView)
        dropShadowView.center = containerView.center
        presentationController.dimmingView.alpha = 0.0

        let animationProgress = (detent == .medium) ? 0.5 : 1.0
        let animation = presentationController.animation(for: animationProgress, in: containerView)
        
        animator.addAnimations {
            dropShadowView.transform = animation.transform
            presentationController.dimmingView.alpha = animation.alpha
        }
        
        animator.addCompletion { position in
            switch position {
            case .start:
                fromViewController.beginAppearanceTransition(false, animated: true)
            case .current:
                break
            case .end:
                presentationController.selectedDetent = detent
                fromViewController.endAppearanceTransition()
                let didComplete = !transitionContext.transitionWasCancelled
                transitionContext.completeTransition(didComplete)
            @unknown default:
                break
            }
        }
        
        animator.startAnimation()
    }
}
