import UIKit

/// An object that represents a height where a sheet naturally rests.
public enum Detent: Hashable {
    /// The system's medium detent.
    case medium
    /// The system's large detent.
    case large
    /// A detent with a constant height.
    case constant(height: CGFloat)
}

@MainActor @objc public protocol ModalSheetPresentationControllerDelegate: UIAdaptivePresentationControllerDelegate {
    // Called when the selected detent of the sheet changes in response to user interaction.
    // Not called if selectedDetentIdentifier is programmatically set.
    @objc optional func sheetPresentationControllerDidChangeSelectedDetent(_ sheetPresentationController: ModalSheetPresentationController)
}

@MainActor open class ModalSheetPresentationController: UIPresentationController {

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

    enum AnimationType {
        case dismiss
        case attemptToDismiss
        case setDetent(Detent)
    }

    let dimmingView: UIView
    let grabberView: UIView
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
    public var detents: [Detent] = [.large]

    /// The identifier of the selected detent. When nil or the identifier is not found in detents, the sheet is displayed at the smallest detent.
    /// Default: nil
    public var selectedDetent: Detent?

    /// The identifier of the largest detent that is not dimmed. When nil or the identifier is not found in detents, all detents are dimmed.
    /// Default: nil
    public var largestUndimmedDetent: Detent?

    public func setSelectedDetent(_ selectedDetent: Detent, animated: Bool) {
        guard detents.contains(selectedDetent),
              let containerView = containerView,
              self.selectedDetent != selectedDetent else { return }
        
        let animator = animator(for: .setDetent(selectedDetent), in: containerView)
        animator.startAnimation()
    }
            
    override public init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        self.dimmingView = UIView()
        self.grabberView = UIView()
        self.touchForwardingView = TouchForwardingView()
        self.panGestureRecognizer = UIPanGestureRecognizer()
        self.tapGestureRecognizer = UITapGestureRecognizer()
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    override public func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        guard let containerView, let presentedView else {
            return
        }
        configureContainerView(containerView)

        addDimmingView(to: containerView)
        addGrabberView(to: presentedView)
        
        addPanGestureRecognizer(to: containerView)
        addTapGestureRecognizer(to: containerView)
    }

//    func initialDetentForPresenting() -> Detent {
//        if let selectedDetent, detents.contains(selectedDetent) {
//            return selectedDetent
//        } else if detents.contains(.medium) {
//            return .medium
//        } else {
//            return .large
//        }
//    }

    func preferredContentSize(for detent: Detent) -> CGSize {
        guard let containerView = containerView else { return .zero }
        let safeAreaInsets = containerView.safeAreaInsets
        switch detent {
        case .medium:
            var contentSize = containerView.bounds.size
            contentSize.height /= 2
            contentSize.height += safeAreaInsets.bottom
            return contentSize
        case .large:
            let topOffsetAddition: CGFloat = 10.0
            var contentSize = containerView.bounds.size
            contentSize.height -= (safeAreaInsets.top + topOffsetAddition)
            return contentSize

        case .constant(let height):
            return CGSize(width: containerView.bounds.width, height: height)
        }
    }
    
    private func addGrabberView(to presentedView: UIView) {
        grabberView.backgroundColor = UIColor.grabberBackground
        grabberView.layer.cornerRadius = 2.5
        grabberView.translatesAutoresizingMaskIntoConstraints = false
        presentedView.addSubview(grabberView)
        grabberView.topAnchor.constraint(equalTo: presentedView.topAnchor, constant: 5.0).isActive = true
        grabberView.centerXAnchor.constraint(equalTo: presentedView.centerXAnchor).isActive = true
        grabberView.widthAnchor.constraint(equalToConstant: 36.0).isActive = true
        grabberView.heightAnchor.constraint(equalToConstant: 5.0).isActive = true
        grabberView.isHidden = !prefersGrabberVisible
    }
    
    private func addDimmingView(to containerView: UIView) {
        dimmingView.backgroundColor = UIColor.dimmBackground
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dimmingView)
        dimmingView.isUserInteractionEnabled = (largestUndimmedDetent == .none)
        dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
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

        defer {
            recognizer.setTranslation(.zero, in: containerView)
        }

        switch recognizer.state {
        case .changed:
            var presentedViewFrame = presentedView.frame
            let translation = recognizer.translation(in: containerView)
            let maxHeight = containerView.bounds.height - containerView.safeAreaInsets.top
            presentedViewFrame.origin.y = max(containerView.safeAreaInsets.top, presentedView.frame.minY + translation.y)
            presentedViewFrame.size.height = min(presentedView.frame.height - translation.y, maxHeight)
            presentedView.frame = presentedViewFrame
            presentedView.layoutIfNeeded()
            print("translation: \(translation)")
        case .ended, .cancelled:
            let velocity = recognizer.velocity(in: containerView)
            print("Velocity: \(velocity)")
            let animationType = animationType(for: presentedView.frame.height, velocity: velocity)
            print(animationType)
            let animator = animator(for: animationType, in: containerView)
            animator.startAnimation()
        default:
            break
        }
    }

    func animationType(for presentedViewHeight: CGFloat, velocity: CGPoint)-> AnimationType {
        let sortedDetents = detents.sorted { (detent1, detent2) -> Bool in
            let detent1Height = preferredContentSize(for: detent1).height
            let detent2Height = preferredContentSize(for: detent2).height
            return detent1Height < detent2Height
        }

        let requiredMinVelocity = containerView!.bounds.height / 2.0

        if abs(velocity.y) < requiredMinVelocity {
            print("Velocity is small")
            return .setDetent(selectedDetent ?? sortedDetents.first ?? .large)
        }

        for (index, detent) in sortedDetents.enumerated() {
            let detentHeight = preferredContentSize(for: detent).height
            if velocity.y > 0 {
                if detentHeight <= presentedViewHeight {
                    return .setDetent(detent)
                } else if index == 0 {
//                    if presentedViewController.isModalInPresentation {
//                        return .attemptToDismiss
//                    } else {
                        return .dismiss
//                    }
                }
            } else {
                // moving up
                if detentHeight >= presentedViewHeight {
                    return .setDetent(detent)
                } else if index == sortedDetents.count - 1 {
                    return .setDetent(sortedDetents[sortedDetents.count - 1])
                }
            }
        }

        return .attemptToDismiss
    }

    func animator(for animationType: AnimationType, in containerView: UIView) -> UIViewPropertyAnimator {
        let timingParameters = UISpringTimingParameters(damping: 1, response: 0.3)
        let animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        let presentedView = presentedView!.parentDropShadowView!
        // Add animations
        animator.addAnimations {
            switch animationType {
            case .dismiss:
                break
            case .attemptToDismiss:
                break
            case .setDetent(let detent):
                var presentedViewFrame = presentedView.frame
                let contentSize = self.preferredContentSize(for: detent)
                presentedViewFrame.origin.y = containerView.bounds.height - contentSize.height
                presentedViewFrame.size.height = contentSize.height
                presentedView.frame = presentedViewFrame
                presentedView.layoutIfNeeded()
            }
        }
        
        // Add completion
        animator.addCompletion { position in
            switch position {
            case .start:
                break
            case .end:
                if case let .setDetent(detent) = animationType {
                    self.selectedDetent = detent
                    if let sheetPresentationDelegate = self.delegate as? ModalSheetPresentationControllerDelegate {
                        sheetPresentationDelegate.sheetPresentationControllerDidChangeSelectedDetent?(self)
                    }
                }

                if case .dismiss = animationType {
                    self.presentedViewController.dismiss(animated: true) {
                        self.delegate?.presentationControllerDidDismiss?(self)
                    }
                }
            case .current:
                break
            @unknown default:
                break
            }
        }
        
        return animator
    }
}


private extension ModalSheetPresentationController {

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
