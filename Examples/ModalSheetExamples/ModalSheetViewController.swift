import UIKit
import ModalSheet

final class ModalSheetViewController: UIViewController {
    private var _preferredCornerRadius: CGFloat? = nil
    private var _prefersGrabberVisible: Bool = false
    private var _detents: [Detent] = [.large]
    private var _selectedDetent: Detent? = nil
    private var _largestUndimmedDetent: Detent? = nil

    var displaylink: CADisplayLink!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        displaylink = CADisplayLink(target: self, selector: #selector(linkTriggered))
        //displaylink.add(to: .main, forMode: .default)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    @objc func linkTriggered(displaylink: CADisplayLink) {
        print("\(displaylink.timestamp)")

        print("transform.isIdentity", view.transform.isIdentity)
        print("transform3D.isIdentity", CATransform3DIsIdentity(view.transform3D))
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
