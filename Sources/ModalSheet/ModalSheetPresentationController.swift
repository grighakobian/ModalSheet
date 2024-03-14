import UIKit

@objc public protocol ModalSheetPresentationControllerDelegate: UIAdaptivePresentationControllerDelegate {
    // Called when the selected detent of the sheet changes in response to user interaction.
    // Not called if selectedDetentIdentifier is programmatically set.
    @objc optional func sheetPresentationControllerDidChangeSelectedDetent(_ sheetPresentationController: ModalSheetPresentationController)
}

public class ModalSheetPresentationController: UIPresentationController {
    /// An object that represents a height where a sheet naturally rests.
    public enum Detent: Int, Hashable {
        /// The system's medium detent.
        case medium
        /// The system's large detent.
        case large
    }
    
    /// An object that represent animation props.
    struct Animation {
        /// The dimming view alpha.
        let alpha: CGFloat
        /// The presented view transform.
        let transform: CGAffineTransform
    }
    
    /// An object that represent the action item when user interaction ended.
    enum ActionItemAtEnd {
        case dismiss
        case attemptToDismiss
        case setDetent(Detent)
    }
    
    let dimmingView: DimmingView
    let grabberView: GrabberView
    let touchForwardingView: TouchForwardingView
    let panGestureRecognizer: UIPanGestureRecognizer
    let tapGestureRecognizer: UITapGestureRecognizer
   
    /// The preferred corner radius of the sheet when presented.
    /// This value is only respected when the sheet is at the front of its stack.
    /// Default: nil
    public var preferredCornerRadius: CGFloat?
    
    /// Set to YES to show a grabber at the top of the sheet.
    /// Default: NO
    public var prefersGrabberVisible: Bool = false {
        didSet { grabberView.isHidden = !prefersGrabberVisible }
    }

    /// The array of detents that the sheet may rest at.
    /// This array must have at least one element.
    /// Detents must be specified in order from smallest to largest height.
    /// Default: an array of only [UISheetPresentationControllerDetent largeDetent]
    public var detents: [ModalSheetPresentationController.Detent] = [.large]

    /// The identifier of the selected detent. When nil or the identifier is not found in detents, the sheet is displayed at the smallest detent.
    /// Default: nil
    public var selectedDetent: ModalSheetPresentationController.Detent?

    /// The identifier of the largest detent that is not dimmed. When nil or the identifier is not found in detents, all detents are dimmed.
    /// Default: nil
    public var largestUndimmedDetent: ModalSheetPresentationController.Detent?

    public func setSelectedDetent(_ selectedDetent: ModalSheetPresentationController.Detent, animated: Bool) {
        guard detents.contains(selectedDetent),
              let containerView = containerView,
              self.selectedDetent != selectedDetent else { return }
        
        let animator = animator(for: .setDetent(selectedDetent), in: containerView)
        animator.startAnimation()
    }
            
    override public init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        self.dimmingView = DimmingView()
        self.grabberView = GrabberView()
        self.touchForwardingView = TouchForwardingView()
        self.panGestureRecognizer = UIPanGestureRecognizer()
        self.tapGestureRecognizer = UITapGestureRecognizer()
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    override public func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        guard let containerView = containerView,
              let presentedView = presentedView else { return }
        
        configureContainerView(containerView)
        configurePresentedView(presentedView)

        addDimmingView(to: containerView)
        addGrabberView(to: presentedView)
        
        addPanGestureRecognizer(to: containerView)
        addTapGestureRecognizer(to: containerView)
    }
    
    public func preferredContentSize(for detent: ModalSheetPresentationController.Detent) -> CGSize {
        guard let containerView = containerView else { return .zero }
        let safeAreaInsets = containerView.safeAreaInsets
        let topOffsetAddition: CGFloat = 10.0
        switch detent {
        case .medium:
            var contentSize = containerView.bounds.size
            let verticalSpacing = safeAreaInsets.top + safeAreaInsets.bottom
            var contentHeight = contentSize.height
            contentHeight = (contentHeight - (verticalSpacing + topOffsetAddition)) / 2 + verticalSpacing
            contentSize.height = contentHeight
            return contentSize
        case .large:
            var contentSize = containerView.bounds.size
            contentSize.height -= (safeAreaInsets.top + topOffsetAddition)
            return contentSize
        }
    }
    
    private func addGrabberView(to presentedView: UIView) {
        grabberView.translatesAutoresizingMaskIntoConstraints = false
        presentedView.addSubview(grabberView)
        grabberView.topAnchor.constraint(equalTo: presentedView.topAnchor, constant: 5.0).isActive = true
        grabberView.centerXAnchor.constraint(equalTo: presentedView.centerXAnchor).isActive = true
        grabberView.widthAnchor.constraint(equalToConstant: 36.0).isActive = true
        grabberView.heightAnchor.constraint(equalToConstant: 5.0).isActive = true
        grabberView.isHidden = !prefersGrabberVisible
    }
    
    private func addDimmingView(to containerView: UIView) {
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dimmingView)
        dimmingView.isUserInteractionEnabled = (largestUndimmedDetent == .none)
        dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
    private func configurePresentedView(_ presentedView: UIView) {
        let preferredCornerRadius = preferredCornerRadius ?? 8.0
        presentedView.layer.cornerRadius = preferredCornerRadius
        presentedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedView.clipsToBounds = true
    }
    
    private func configureContainerView(_ containerView: UIView) {
        containerView.backgroundColor = .clear
        touchForwardingView.passthroughViews = [presentingViewController.view]
        touchForwardingView.translatesAutoresizingMaskIntoConstraints = false
        containerView.insertSubview(touchForwardingView, at: 0)
        touchForwardingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        touchForwardingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        touchForwardingView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        touchForwardingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
    private func addPanGestureRecognizer(to containerView: UIView) {
        // Add a pan gesture recognizer for interactive transition
        panGestureRecognizer.addTarget(self, action: #selector(panned(_:)))
        panGestureRecognizer.cancelsTouchesInView = false
        containerView.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func addTapGestureRecognizer(to containerView: UIView) {
        // Add a tap gesture recognizer for top to dismiss
        tapGestureRecognizer.addTarget(self, action: #selector(tapped(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        containerView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func tapped(_ sender: UITapGestureRecognizer) {
        if largestUndimmedDetent == nil && selectedDetent == .medium {
            let location = sender.location(in: containerView)
            if presentedView?.frame.contains(location) == false {
                presentedViewController.dismiss(animated: true)
            }
        }
    }
    
    @objc private func panned(_ recognizer: UIPanGestureRecognizer) {
        guard let containerView = containerView,
              let presentedView = presentedView?.parentDropShadowView else { return }
        
        defer { recognizer.setTranslation(.zero, in: containerView) }
        
        switch recognizer.state {
        case .changed:
            let initialTransform = presentedView.transform
            let translation = recognizer.translation(in: containerView)
            var transform = initialTransform.translatedBy(x: 0, y: translation.y)
            let safeAreaInsets = containerView.safeAreaInsets
            transform.ty = max(transform.ty, safeAreaInsets.top)
            let animationProgress = animationProgress(for: transform, in: containerView)
            let animation = animation(for: animationProgress, in: containerView, and: 0.0)
            apply(animation: animation)
        case .ended, .cancelled:
            let velocity = recognizer.velocity(in: containerView)
            let progress = animationProgress(for: presentedView.transform, in: containerView)
            let actionItemAtEnd = actionItemAtEnd(for: progress, and: velocity, in: containerView)
            if case .dismiss = actionItemAtEnd {
                if delegate?.presentationControllerShouldDismiss?(self) == true {
                    delegate?.presentationControllerWillDismiss?(self)
                }
            } else if case .attemptToDismiss = actionItemAtEnd {
                delegate?.presentationControllerDidAttemptToDismiss?(self)
            }
            let animator = animator(for: actionItemAtEnd, in: containerView)
            animator.startAnimation()
        default:
            break
        }
    }
    
    /// Apply the animation.
    /// - Parameter animation: An Animation object that represents animation props.
    func apply(animation: Animation) {
        dimmingView.alpha = animation.alpha
        presentedView?.parentDropShadowView?.transform = animation.transform
    }
    
    /// Get the animation progress based on pan gesture translation in container view.
    /// - Parameters:
    ///   - translation: The translation of the pan gesture recognizer in container view.
    ///   - containerView: The presentation controller container view
    /// - Returns: A CGFloat value representing the animation progress.
    func animationProgress(for translation: CGAffineTransform, in containerView: UIView) -> CGFloat {
        let currentOffset = translation.ty - containerView.safeAreaInsets.top
        let containerHeight = containerView.bounds.height - containerView.safeAreaInsets.top
        let progress = 1.0 - (currentOffset / containerHeight)
        return progress
    }
    
    /// Get the animation props based on animation progress and presented view top offset addition.
    /// - Parameters:
    ///   - progress: The animation progress.
    ///   - topOffsetAddition: The presented view top offset addition.
    /// - Returns: An Animation object that represents animation props.
    func animation(for progress: CGFloat, in containerView: UIView, and topOffsetAddition: CGFloat = 10.0) -> Animation {
        let contentHeight = containerView.frame.height
        let safeAreaInsets = containerView.safeAreaInsets
        let topOffset = safeAreaInsets.top + topOffsetAddition
        let offset = ((contentHeight - topOffset) * (1 - progress)) + topOffset
        let presentedViewTransform = CGAffineTransform(translationX: 0, y: offset)
        
        var dimmingViewAlpha = min(1.0, (progress / 0.5))
        if largestUndimmedDetent == .medium {
            dimmingViewAlpha = min(1.0, ((progress-0.5) / 0.5))
        } else if largestUndimmedDetent == .large {
            dimmingViewAlpha = 0.0
        }
       
        return Animation(alpha: dimmingViewAlpha, transform: presentedViewTransform)
    }
    
    func animator(for actionItemAtEnd: ActionItemAtEnd, in containerView: UIView) -> UIViewPropertyAnimator {
        let timingParameters = UISpringTimingParameters(damping: 0.9, response: 0.3)
        let animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        
        // Add animations
        animator.addAnimations {
            // Animation progress for dissmiss action.
            var animationProgress: CGFloat = 0.0
            if case .setDetent(.medium) = actionItemAtEnd {
                // Animation progress for medium detent.
                animationProgress = 0.5
            } else if case .setDetent(.large) = actionItemAtEnd {
                // Animation progress for large detent.
                animationProgress = 1.0
            } else if case .attemptToDismiss = actionItemAtEnd {
                switch self.selectedDetent {
                case .medium:
                    animationProgress = 0.5
                case .large:
                    animationProgress = 1.0
                case .none:
                    break
                }
            }
            let animation = self.animation(for: animationProgress, in: containerView)
            self.apply(animation: animation)
        }
        
        // Add completion
        animator.addCompletion { position in
            if position == .end {
                if case .setDetent(.medium) = actionItemAtEnd {
                    self.selectedDetent = .medium
                    if let sheetPresentationDelegate = self.delegate as? ModalSheetPresentationControllerDelegate {
                        sheetPresentationDelegate.sheetPresentationControllerDidChangeSelectedDetent?(self)
                    }
                } else if case .setDetent(.large) = actionItemAtEnd {
                    self.selectedDetent = .large
                    if let sheetPresentationDelegate = self.delegate as? ModalSheetPresentationControllerDelegate {
                        sheetPresentationDelegate.sheetPresentationControllerDidChangeSelectedDetent?(self)
                    }
                } else if case .attemptToDismiss = actionItemAtEnd {
                    // Do nothing
                } else if case .dismiss = actionItemAtEnd {
                    self.presentedViewController.dismiss(animated: true) {
                        self.delegate?.presentationControllerDidDismiss?(self)
                    }
                }
            }
        }
        
        return animator
    }
    
    /// Decide the action item item when user interaction ended.
    /// - Parameters:
    ///   - progress: The animation progress.
    ///   - velocity: The pan gesture velocity in container view.
    ///   - containerView: The presentation controller container view.
    /// - Returns: An object that represent the action item when user interaction ended.
    func actionItemAtEnd(for progress: CGFloat, and velocity: CGPoint, in containerView: UIView) -> ActionItemAtEnd {
        let velocityChange = velocity.y
        let requiredMinVelocity = containerView.bounds.height / 2.0
        
        if abs(velocityChange) < requiredMinVelocity {
            return .setDetent(selectedDetent ?? .medium)
        }
        
        if progress > 0.5 {
             if velocityChange < -requiredMinVelocity {
                 if detents.contains(.large) {
                     return .setDetent(.large)
                 } else if detents.contains(.medium) {
                     return .setDetent(.medium)
                 } else {
                     if presentedViewController.isModalInPresentation {
                         return .attemptToDismiss
                     } else if delegate?.presentationControllerShouldDismiss?(self) == false {
                         return .attemptToDismiss
                     }
                     return .dismiss
                 }
             } else {
                 if detents.contains(.medium) {
                     return .setDetent(.medium)
                 } else {
                     if presentedViewController.isModalInPresentation {
                         return .attemptToDismiss
                     } else if delegate?.presentationControllerShouldDismiss?(self) == false {
                         return .attemptToDismiss
                     }
                     return .dismiss
                 }
             }
        } else {
            if velocityChange > requiredMinVelocity {
                if presentedViewController.isModalInPresentation {
                    return .attemptToDismiss
                } else if delegate?.presentationControllerShouldDismiss?(self) == false {
                    return .attemptToDismiss
                }
                return .dismiss
            } else {
                if detents.contains(.medium) {
                    return .setDetent(.medium)
                } else {
                    return .setDetent(.large)
                }
            }
        }
    }
}
