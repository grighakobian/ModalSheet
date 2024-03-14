//
//  ModalSheetTransitioning.swift
//  ModalSheetTransition
//
//  Created by Grigor Hakobyan on 18.02.22.
//

import UIKit

public protocol ModalSheetTransitioning: UIViewController {
    /// The delegate object for managing adaptive presentations.
    var delegate: ModalSheetPresentationControllerDelegate? { get }

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
    var detents: [ModalSheetPresentationController.Detent] { get }
        
    /// The identifier of the selected detent. When nil or the identifier is not found in detents, the sheet is displayed at the smallest detent.
    /// Default: nil
    var selectedDetent: ModalSheetPresentationController.Detent? { get }

    /// The identifier of the largest detent that is not dimmed. When nil or the identifier is not found in detents, all detents are dimmed.
    /// Default: nil
    var largestUndimmedDetent: ModalSheetPresentationController.Detent? { get }
}


// MARK: - ModalSheetTransitioning defaults

extension ModalSheetTransitioning {
    
    var delegate: ModalSheetPresentationControllerDelegate? {
        return nil
    }
    
    var preferredCornerRadius: CGFloat? {
        return nil
    }

    var prefersGrabberVisible: Bool {
        return false
    }

    var detents: [ModalSheetPresentationController.Detent] {
        return [.large]
    }
    
    var selectedDetent: ModalSheetPresentationController.Detent? {
        return nil
    }

    var largestUndimmedDetent: ModalSheetPresentationController.Detent? {
        return nil
    }
}
