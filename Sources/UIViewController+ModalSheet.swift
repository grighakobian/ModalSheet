import UIKit

public extension UIViewController {
    func presentModalSheet(
        _ viewControllerToPresent: UIViewController,
        transitionOptions: ModalSheetTransitionOptions = .system,
        delegate: ModalSheetPresentationControllerDelegate? = nil,
        animated: Bool,
        completion: (()->Void)? = nil) {
        viewControllerToPresent.modalPresentationStyle = .custom
        viewControllerToPresent.transitioningDelegate = ModalSheetTransition(transitionOptions: transitionOptions, delegate: delegate)
        present(viewControllerToPresent, animated: animated, completion: completion)
    }
}
