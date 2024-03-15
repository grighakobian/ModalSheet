import UIKit

public class ModalSheetPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    public let detents: [Detent]
    public let selectedDetent: Detent?
    public let largestUndimmedDetent: Detent?
    public let animator: UIViewPropertyAnimator
    
    public init(detents: [Detent], selectedDetent: Detent?, largestUndimmedDetent: Detent?) {
        self.detents = detents
        self.selectedDetent = selectedDetent
        self.largestUndimmedDetent = largestUndimmedDetent
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
              let presentationView = transitionContext.view(forKey: .to),
              let presentationController = toViewController.presentationController as? ModalSheetPresentationController else {
            transitionContext.completeTransition(false)
            return
        }

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

        let containerView = transitionContext.containerView
        let dropShadowView = DropShadowView()

        let contentView = UIView()
        contentView.clipsToBounds = true
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.layer.cornerRadius = presentationController.preferredCornerRadius ?? 8.0

        presentationView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(presentationView)
        presentationView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        presentationView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        presentationView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        presentationView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        contentView.translatesAutoresizingMaskIntoConstraints = false
        dropShadowView.addSubview(contentView)
        contentView.topAnchor.constraint(equalTo: dropShadowView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: dropShadowView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: dropShadowView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: dropShadowView.bottomAnchor).isActive = true

        dropShadowView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dropShadowView)
        dropShadowView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        dropShadowView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        dropShadowView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        dropShadowView.heightAnchor.constraint(equalToConstant: preferredContentSize.height).isActive = true

        presentationController.dimmingView.alpha = 0.0
        dropShadowView.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)

        animator.addAnimations { [largestUndimmedDetent] in
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
