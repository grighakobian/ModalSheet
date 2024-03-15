import UIKit

@MainActor final class ModalSheetPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let animator: UIViewPropertyAnimator

    override init() {
        let springTimingParameters = UISpringTimingParameters(damping: 1.0, response: 0.4)
        self.animator = UIViewPropertyAnimator(duration: 0.0, timingParameters: springTimingParameters)
        super.init()
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animator.duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController = transitionContext.viewController(forKey: .to),
              let presentingView = transitionContext.view(forKey: .to),
              let presentationController = toViewController.presentationController as? ModalSheetPresentationController else {
            transitionContext.completeTransition(false)
            return
        }

        let detents = presentationController.detents
        let selectedDetent = presentationController.selectedDetent
        let largestUndimmedDetent = presentationController.largestUndimmedDetent

        let detent: Detent = {
            if let selectedDetent, detents.contains(selectedDetent) {
                return selectedDetent
            } else if detents.contains(.medium) {
                return .medium
            } else {
                return .large
            }
        }()

        let preferredContentSize = presentationController.preferredContentSize(for: detent)
        let initialFrame = CGRect(origin: .zero, size: preferredContentSize)

        let containerView = transitionContext.containerView

        presentingView.frame = initialFrame
        presentingView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        let dropShadowView = DropShadowView()
        dropShadowView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        var frame = initialFrame
        frame.origin.y = containerView.bounds.height - initialFrame.height
        dropShadowView.frame = frame

        let contentView = UIView()
        contentView.frame = initialFrame
        contentView.clipsToBounds = true
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.layer.cornerRadius = presentationController.preferredCornerRadius ?? 8.0

        contentView.addSubview(presentingView)
        dropShadowView.addSubview(contentView)
        containerView.addSubview(dropShadowView)

        presentationController.dimmingView.alpha = 0.0
        dropShadowView.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)

        animator.addAnimations {
            if detent != largestUndimmedDetent {
                presentationController.dimmingView.alpha = 1.0
            }
            dropShadowView.transform = CGAffineTransform.identity
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
