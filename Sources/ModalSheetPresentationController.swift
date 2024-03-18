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
        let dimmingViewAlpha: CGFloat
        /// The presented view frame.
        let presentedViewFrame: CGRect
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

    let grabber: UIView
    let dimmingView: UIView
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
        didSet { grabber.isHidden = !prefersGrabberVisible }
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
            
    override public init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        self.dimmingView = UIView()
        self.grabber = UIView()
        self.touchForwardingView = TouchForwardingView()
        self.panGestureRecognizer = UIPanGestureRecognizer()
        self.tapGestureRecognizer = UITapGestureRecognizer()
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    open override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()

        guard let containerView, let presentedView else { return }

        let grabberSize = CGSize(width: 36, height: 5)
        let grabberPosition = CGPoint(x: presentedView.frame.midX - grabberSize.width / 2, y: 5)
        grabber.frame = CGRect(origin: grabberPosition, size: grabberSize)

        dimmingView.frame = containerView.bounds
        touchForwardingView.frame = containerView.bounds
    }

    override public func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        guard let containerView, let presentedView else { return }

        // Add touch forwarding view
        containerView.backgroundColor = .clear
//        touchForwardingView.passthroughViews = [presentingViewController.view]
        touchForwardingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        touchForwardingView.isUserInteractionEnabled = false
        containerView.insertSubview(touchForwardingView, at: 0)

        // Add grabber
        grabber.layer.cornerRadius = 2.5
        grabber.clipsToBounds = true
        grabber.backgroundColor = UIColor.grabberBackground
        grabber.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        grabber.isHidden = !prefersGrabberVisible
        presentedView.addSubview(grabber)

        // Add dimming view
        dimmingView.alpha = 0
        dimmingView.backgroundColor = UIColor.dimmBackground
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimmingView.isUserInteractionEnabled = (largestUndimmedDetent == .none)
        containerView.addSubview(dimmingView)

        // Add a pan gesture recognizer for interactive transition
        panGestureRecognizer.addTarget(self, action: #selector(panned(_:)))
        panGestureRecognizer.cancelsTouchesInView = false
        containerView.addGestureRecognizer(panGestureRecognizer)

        // Add a tap gesture recognizer for top to dismiss
        tapGestureRecognizer.addTarget(self, action: #selector(tapped(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        containerView.addGestureRecognizer(tapGestureRecognizer)
    }

    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { [unowned self] coordinatorContext in
            let animation = animation(for: presentingDetent())
            self.containerView?.frame = coordinatorContext.containerView.bounds
            self.presentedView?.parentDropShadowView?.frame = animation.presentedViewFrame
        })
    }

    func sortDetentsByContentSize(_ detents: [Detent])-> [Detent] {
        return detents.sorted { (lhsValue, rhsValue) -> Bool in
            let detent1Height = preferredContentSize(for: lhsValue).height
            let detent2Height = preferredContentSize(for: rhsValue).height
            return detent1Height < detent2Height
        }
    }

    func presentingDetent()-> Detent {
        if let selectedDetent {
            return selectedDetent
        }
        let sortedDetents = sortDetentsByContentSize(detents)
        return sortedDetents.first ?? .large
    }

    func animation(for detent: Detent)-> Animation {
        let containerBounds = containerView!.bounds
        var presentedViewFrame = containerBounds
        presentedViewFrame.size = preferredContentSize(for: detent)
        presentedViewFrame.origin.y = containerBounds.height - presentedViewFrame.size.height
        var dimmingViewAlpha: CGFloat = 1.0
        if let largestUndimmedDetent = largestUndimmedDetent {
            let targetDetentSize = preferredContentSize(for: detent)
            let largestUndimmedDetentSize = preferredContentSize(for: largestUndimmedDetent)
            if targetDetentSize.height < largestUndimmedDetentSize.height {
                dimmingViewAlpha = 0.0
            }
        }
        return Animation(dimmingViewAlpha: dimmingViewAlpha, presentedViewFrame: presentedViewFrame)
    }

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
    
    @objc private func tapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: containerView)
        if presentedView?.frame.contains(location) == false {
            presentedViewController.dismiss(animated: true)
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
            let animator = animator(for: animationType, in: containerView, velocity: velocity)
            animator.startAnimation()
        default:
            break
        }
    }

    func animationType(for presentedViewHeight: CGFloat, velocity: CGPoint)-> AnimationType {
        let sortedDetents = sortDetentsByContentSize(detents)

        if abs(velocity.y) < 100 {
            print("Velocity is small")
            return .setDetent(presentingDetent())
        }

        if velocity.y > 0 {
            if velocity.y > 1000 {
                return .setDetent(sortedDetents.first!)
            }
            for detent in sortedDetents.reversed() {
                let detentHeight = preferredContentSize(for: detent).height
                if detentHeight <= presentedViewHeight {
                    return .setDetent(detent)
                } else if detent == sortedDetents.first {
                    return .dismiss
                }
            }
        } else {
            if abs(velocity.y) > 1000 {
                return .setDetent(sortedDetents.last!)
            }
            // moving up
            for (index, detent) in sortedDetents.enumerated() {
                let detentHeight = preferredContentSize(for: detent).height
                if detentHeight >= presentedViewHeight {
                    return .setDetent(detent)
                } else if index == sortedDetents.count - 1 {
                    return .setDetent(sortedDetents[sortedDetents.count - 1])
                }
            }
        }

        return .attemptToDismiss
    }

    func animator(for animationType: AnimationType, in containerView: UIView, velocity: CGPoint) -> UIViewPropertyAnimator {
        let presentedView = presentedView!.parentDropShadowView!

        let detent: Detent = {
            switch animationType {
            case .dismiss:
                return presentingDetent()
            case .attemptToDismiss:
                return presentingDetent()
            case .setDetent(let detent):
                return detent
            }
        }()

        let preferredContentSize = self.preferredContentSize(for: detent)
        let distance = abs(preferredContentSize.height - presentedView.frame.height)
        let initialVelocity = -1.0 * velocity.y / distance

        let timingParameters = UISpringTimingParameters(damping: 1, response: 0.3, initialVelocity: CGVector(dx: initialVelocity, dy: initialVelocity))
        let animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        // Add animations
        animator.addAnimations {
            switch animationType {
            case .dismiss:
                var presentedViewFrame = presentedView.frame
                presentedViewFrame.origin.y = containerView.bounds.height
                self.dimmingView.alpha = 0
                presentedView.frame = presentedViewFrame
                presentedView.layoutIfNeeded()
            case .attemptToDismiss:
                let detent = self.presentingDetent()
                let animation = self.animation(for: detent)
                self.dimmingView.alpha = animation.dimmingViewAlpha
                presentedView.frame = animation.presentedViewFrame
                presentedView.layoutIfNeeded()
            case .setDetent(let detent):
                let animation = self.animation(for: detent)
                self.dimmingView.alpha = animation.dimmingViewAlpha
                presentedView.frame = animation.presentedViewFrame
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
