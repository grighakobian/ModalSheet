import UIKit

@MainActor public protocol ModalSheetTransitioning: UIViewController {
    /// The delegate object for managing adaptive presentations.
    var modalSheetDelegate: ModalSheetPresentationControllerDelegate? { get }

    /// The preferred corner radius of the sheet when presented.
    /// This value is only respected when the sheet is at the front of its stack.
    /// Default: nil
    var preferredCornerRadius: CGFloat? { get }

    /// Set to YES to show a grabber at the top of the sheet.
    /// Default: NO
    var prefersGrabberVisible: Bool { get }

    /// The array of detents that the sheet may rest at.
    /// This array must have at least one element.
    /// Detents must be specified in order from smallest to largest height.
    /// Default: an array of only [UISheetPresentationControllerDetent largeDetent]
    var detents: [Detent] { get }
        
    /// The identifier of the selected detent. When nil or the identifier is not found in detents, the sheet is displayed at the smallest detent.
    /// Default: nil
    var selectedDetent: Detent? { get }

    /// The identifier of the largest detent that is not dimmed. When nil or the identifier is not found in detents, all detents are dimmed.
    /// Default: nil
    var largestUndimmedDetent: Detent? { get }
}


// MARK: - ModalSheetTransitioning defaults

public extension ModalSheetTransitioning {
    
    var modalSheetDelegate: ModalSheetPresentationControllerDelegate? {
        return nil
    }
    
    var preferredCornerRadius: CGFloat? {
        return nil
    }

    var prefersGrabberVisible: Bool {
        return false
    }

    var detents: [Detent] {
        return [.large]
    }
    
    var selectedDetent: Detent? {
        return nil
    }

    var largestUndimmedDetent: Detent? {
        return nil
    }
}
