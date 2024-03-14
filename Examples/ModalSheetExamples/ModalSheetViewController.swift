import UIKit
import ModalSheet

final class ModalSheetViewController: UIViewController {
    private var _preferredCornerRadius: CGFloat? = nil
    private var _prefersGrabberVisible: Bool = false
    private var _detents: [ModalSheetPresentationController.Detent] = [.large]
    private var _selectedDetent: ModalSheetPresentationController.Detent? = nil
    private var _largestUndimmedDetent: ModalSheetPresentationController.Detent? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    // MARK: - Setters
    
    func setPreferredCornerRadius(_ preferredCornerRadius: CGFloat?) {
        self._preferredCornerRadius = preferredCornerRadius
    }
    
    func setPrefersGrabberVisible(_ prefersGrabberVisible: Bool) {
        self._prefersGrabberVisible = prefersGrabberVisible
    }

    func setDetents(_ detents: [ModalSheetPresentationController.Detent]) {
        self._detents = detents
    }
    
    func setSelectedDetent(_ selectedDetent: ModalSheetPresentationController.Detent?) {
        self._selectedDetent = selectedDetent
    }
    
    func setLargestUndimmedDetent(_ largestUndimmedDetent: ModalSheetPresentationController.Detent?) {
        self._largestUndimmedDetent = largestUndimmedDetent
    }
}

// MARK: - Private

private extension ModalSheetViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
        
        let closeButton = UIButton(type: .close)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20.0).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
        
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - ModalSheetTransitioning

extension ModalSheetViewController: ModalSheetTransitioning {
    
    var delegate: ModalSheetPresentationControllerDelegate? {
        return self
    }
    
    var preferredCornerRadius: CGFloat? {
        return _preferredCornerRadius
    }

    var prefersGrabberVisible: Bool {
        return _prefersGrabberVisible
    }

    var detents: [ModalSheetPresentationController.Detent] {
        return _detents
    }
    
    var selectedDetent: ModalSheetPresentationController.Detent? {
        return _selectedDetent
    }

    var largestUndimmedDetent: ModalSheetPresentationController.Detent? {
        return _largestUndimmedDetent
    }
}

// MARK: - ModalSheetPresentationControllerDelegate

extension ModalSheetViewController: ModalSheetPresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print(#function)
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        print(#function)
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        print(#function)
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        let shouldDismiss = true
        print(#function, shouldDismiss)
        return shouldDismiss
    }
}
