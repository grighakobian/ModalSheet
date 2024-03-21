import Foundation

open class ModalSheetTransitionOptions: NSObject {
    public var detents: [Detent]
    public var selectedDetent: Detent?
    public var largestUndimmedDetent: Detent?
    public var prefersGrabberVisible: Bool
    public var preferredCornerRadius: CGFloat?

    public init(
        detents: [Detent],
        selectedDetent: Detent? = nil,
        largestUndimmedDetent: Detent? = nil,
        prefersGrabberVisible: Bool = false,
        preferredCornerRadius: CGFloat? = nil) {

        self.detents = detents
        self.selectedDetent = selectedDetent
        self.largestUndimmedDetent = largestUndimmedDetent
        self.prefersGrabberVisible = prefersGrabberVisible
        self.preferredCornerRadius = preferredCornerRadius
    }

}

public extension ModalSheetTransitionOptions {
    static let system = ModalSheetTransitionOptions(
        detents: [.large],
        selectedDetent: nil,
        largestUndimmedDetent: nil,
        prefersGrabberVisible: false,
        preferredCornerRadius: nil
    )
}
