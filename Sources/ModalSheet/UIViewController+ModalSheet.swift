import UIKit

public extension UIViewController {

    func presentModalSheet(_ viewControllerToPresent: ModalSheetTransitioning, animated: Bool, completion: (()->Void)? = nil) {
        viewControllerToPresent.modalPresentationStyle = .custom
        viewControllerToPresent.transitioningDelegate = ModalSheetTransition.shared
        present(viewControllerToPresent, animated: animated, completion: completion)
    }
}
