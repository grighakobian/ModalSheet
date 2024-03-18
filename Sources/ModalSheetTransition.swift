import UIKit

@MainActor final class ModalSheetTransition: NSObject, UIViewControllerTransitioningDelegate {

    static let shared = ModalSheetTransition()
        
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalSheetPresentationAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalSheetDismissalAnimator()
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentedModalSheet = presented as! ModalSheetTransitioning
        let presentationController = ModalSheetPresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.detents = presentedModalSheet.detents
        presentationController.selectedDetent = presentedModalSheet.selectedDetent
        presentationController.largestUndimmedDetent = presentedModalSheet.largestUndimmedDetent
        presentationController.prefersGrabberVisible = presentedModalSheet.prefersGrabberVisible
        presentationController.preferredCornerRadius = presentedModalSheet.preferredCornerRadius
        presentationController.delegate = presentedModalSheet.modalSheetDelegate
        return presentationController
    }
}
