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

        let containerView = transitionContext.containerView

        let detent = presentationController.presentingDetent()
        let animation = presentationController.animation(for: detent)
        let initialFrame = CGRect(origin: .zero, size: animation.presentedViewFrame.size)

        presentingView.frame = initialFrame
        presentingView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        let dropShadowView = DropShadowView()
        dropShadowView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        dropShadowView.frame = initialFrame.offsetBy(dx: 0, dy: containerView.bounds.height)

        let contentView = UIView()
        contentView.frame = initialFrame
        contentView.clipsToBounds = true
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.layer.cornerRadius = presentationController.preferredCornerRadius ?? 8.0

        containerView.addSubview(dropShadowView)
        dropShadowView.addSubview(contentView)
        contentView.addSubview(presentingView)
        containerView.layoutSubviews()

        animator.addAnimations {
            dropShadowView.frame = animation.presentedViewFrame
            presentationController.dimmingView.alpha = animation.dimmingViewAlpha
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
