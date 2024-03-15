import UIKit
import ModalSheet

final class ModalSheetViewController: UIViewController {
    private var _preferredCornerRadius: CGFloat? = nil
    private var _prefersGrabberVisible: Bool = false
    private var _detents: [Detent] = [.large]
    private var _selectedDetent: Detent? = nil
    private var _largestUndimmedDetent: Detent? = nil

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

    func setDetents(_ detents: [Detent]) {
        self._detents = detents
    }
    
    func setSelectedDetent(_ selectedDetent: Detent?) {
        self._selectedDetent = selectedDetent
    }
    
    func setLargestUndimmedDetent(_ largestUndimmedDetent: Detent?) {
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

        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.systemBlue
        button.tintColor = UIColor.white
        button.layer.cornerRadius = 24
        button.setTitle("Show Results", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).isActive = true
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 48).isActive = true
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).isActive = true
        textView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -24).isActive = true
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

    var detents: [Detent] {
        return _detents
    }
    
    var selectedDetent: Detent? {
        return _selectedDetent
    }

    var largestUndimmedDetent: Detent? {
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
