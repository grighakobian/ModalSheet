import UIKit

public class ModalSheetTransition: NSObject, UIViewControllerTransitioningDelegate {
    
    static let shared = ModalSheetTransition()
        
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let presented = presented as? ModalSheetTransitioning else {
            return nil
        }
        return ModalSheetPresentationAnimator(detents: presented.detents, selectedDetent: presented.selectedDetent)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is ModalSheetTransitioning {
            return ModalSheetDismissalAnimator()
        }
        return nil
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        guard let presented = presented as? ModalSheetTransitioning else {
            return nil
        }
        let presentationController = ModalSheetPresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.detents = presented.detents
        presentationController.selectedDetent = presented.selectedDetent
        presentationController.largestUndimmedDetent = presented.largestUndimmedDetent
        presentationController.prefersGrabberVisible = presented.prefersGrabberVisible
        presentationController.preferredCornerRadius = presented.preferredCornerRadius
        presentationController.delegate = presented.delegate
        return presentationController
    }
}
