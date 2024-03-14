import UIKit

extension UIViewController {
    func presentModalSheet(_ viewControllerToPresent: ModalSheetTransitioning, animated: Bool, completion: (()->Void)? = nil) {
        viewControllerToPresent.modalPresentationStyle = .custom
        viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
        let transitioningDelegate = ModalSheetTransition.shared
        viewControllerToPresent.transitioningDelegate = transitioningDelegate
        present(viewControllerToPresent, animated: animated, completion: completion)
    }
}
