import UIKit

@MainActor final class ModalSheetTransition: NSObject, UIViewControllerTransitioningDelegate {

    fileprivate let _uuid: UUID
    let transitionOptions: ModalSheetTransitionOptions
    weak var delegate: ModalSheetPresentationControllerDelegate?

    init(transitionOptions: ModalSheetTransitionOptions, delegate: ModalSheetPresentationControllerDelegate?) {
        self._uuid = UUID()
        self.transitionOptions = transitionOptions
        self.delegate = delegate
        super.init()
        ModalSheetTransitionCache.shared.insert(self)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalSheetPresentationAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalSheetDismissalAnimator(onCompleted: {
            ModalSheetTransitionCache.shared.remove(self)
        })
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = ModalSheetPresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.delegate = delegate
        presentationController.detents = transitionOptions.detents
        presentationController.selectedDetent = transitionOptions.selectedDetent
        presentationController.largestUndimmedDetent = transitionOptions.largestUndimmedDetent
        presentationController.prefersGrabberVisible = transitionOptions.prefersGrabberVisible
        presentationController.preferredCornerRadius = transitionOptions.preferredCornerRadius
        return presentationController
    }
}

final class ModalSheetTransitionCache {
    static let shared: ModalSheetTransitionCache = {
        return ModalSheetTransitionCache()
    }()

    private var cache: [UUID: ModalSheetTransition]

    private init() {
        self.cache = [UUID: ModalSheetTransition]()
    }

    func insert(_ transition: ModalSheetTransition) {
        cache[transition._uuid] = transition
    }

    func remove(_ transition: ModalSheetTransition) {
        cache.removeValue(forKey: transition._uuid)
    }
}

