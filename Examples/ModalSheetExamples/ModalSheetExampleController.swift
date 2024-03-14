import UIKit
import ModalSheet

final class ModalSheetExampleController: UITableViewController {
    // MARK: - Properties
    
    private let modalSheetViewController = ModalSheetViewController()
    
    // MARK: - Outlets
    
    @IBOutlet private weak var detentMediumSwitch: UISwitch!
    @IBOutlet private weak var detentLargeSwitch: UISwitch!
    @IBOutlet private weak var selectedDetentMediumSwitch: UISwitch!
    @IBOutlet private weak var selectedDetentLargeSwitch: UISwitch!
    @IBOutlet private weak var largestUndimmedDetentMediumSwitch: UISwitch!
    @IBOutlet private weak var largestUndimmedDetentLargeSwitch: UISwitch!
    @IBOutlet private weak var isModalInPresentationSwitch: UISwitch!
    @IBOutlet private weak var prefersGrabberVisibleSwitch: UISwitch!
    @IBOutlet private weak var preferredCornerRadiusLabel: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateTransitionOptions()
    }
    
    @IBAction private func presentModal(_ sender: UIButton) {
        modalSheetViewController.isModalInPresentation = isModalInPresentationSwitch.isOn
        presentModalSheet(modalSheetViewController, animated: true)
    }
    
    @IBAction private func presentiOS15Modal(_ sender: UIButton) {
        let modalSheetViewController = ModalSheetViewController()
        modalSheetViewController.isModalInPresentation = isModalInPresentationSwitch.isOn
        
        if #available(iOS 15.0, *) {
            if let sheetPresentationController = modalSheetViewController.sheetPresentationController {
                sheetPresentationController.prefersGrabberVisible = prefersGrabberVisibleSwitch.isOn
                
                var detents: [UISheetPresentationController.Detent] = []
                if detentMediumSwitch.isOn {
                    detents.append(.medium())
                }
                if detentLargeSwitch.isOn {
                    detents.append(.large())
                }
                sheetPresentationController.detents = detents
                
                if selectedDetentMediumSwitch.isOn {
                    sheetPresentationController.selectedDetentIdentifier = .medium
                } else if selectedDetentLargeSwitch.isOn {
                    sheetPresentationController.selectedDetentIdentifier = .large
                } else {
                    sheetPresentationController.selectedDetentIdentifier = nil
                }
                
                if largestUndimmedDetentMediumSwitch.isOn {
                    sheetPresentationController.largestUndimmedDetentIdentifier = .medium
                } else if largestUndimmedDetentLargeSwitch.isOn {
                    sheetPresentationController.largestUndimmedDetentIdentifier = .large
                } else {
                    sheetPresentationController.largestUndimmedDetentIdentifier = nil
                }
            }
            present(modalSheetViewController, animated: true)
        } else {
            presentModal(sender)
        }
    }
    
    @IBAction private func preferredCornerRadiusChanged(_ sender: UISlider) {
        preferredCornerRadiusLabel.text = "Preferred corner radius: \(Int(sender.value))"
        modalSheetViewController.setPreferredCornerRadius(CGFloat(sender.value))
    }
    
    private func updateTransitionOptions() {
        modalSheetViewController.setPrefersGrabberVisible(prefersGrabberVisibleSwitch.isOn)
        
        var detents: [ModalSheetPresentationController.Detent] = []
        if detentMediumSwitch.isOn {
            detents.append(.medium)
        }
        if detentLargeSwitch.isOn {
            detents.append(.large)
        }
        modalSheetViewController.setDetents(detents)
        
        if selectedDetentMediumSwitch.isOn {
            modalSheetViewController.setSelectedDetent(.medium)
        } else if selectedDetentLargeSwitch.isOn {
            modalSheetViewController.setSelectedDetent(.large)
        } else {
            modalSheetViewController.setSelectedDetent(nil)
        }
        
        if largestUndimmedDetentMediumSwitch.isOn {
            modalSheetViewController.setLargestUndimmedDetent(.medium)
        } else if largestUndimmedDetentLargeSwitch.isOn {
            modalSheetViewController.setLargestUndimmedDetent(.large)
        } else {
            modalSheetViewController.setLargestUndimmedDetent(nil)
        }
    }
    
    @IBAction private func onPreferancesChanged(_ sender: UISwitch) {
        if sender === selectedDetentMediumSwitch {
            if sender.isOn {
                selectedDetentLargeSwitch.setOn(false, animated: true)
            }
        } else if sender === selectedDetentLargeSwitch {
            if sender.isOn {
                selectedDetentMediumSwitch.setOn(false, animated: true)
            }
        } else if sender === largestUndimmedDetentMediumSwitch {
            if sender.isOn {
                largestUndimmedDetentLargeSwitch.setOn(false, animated: true)
            }
        } else if sender === largestUndimmedDetentLargeSwitch {
            if sender.isOn {
                largestUndimmedDetentMediumSwitch.setOn(false, animated: true)
            }
        }
        updateTransitionOptions()
    }
}
