import UIKit

final class TouchForwardingView: UIView {
    
    var passthroughViews = [UIView]()

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled else {
            return nil
        }
        let hitView = super.hitTest(point, with: event)
        if hitView != self {
            return hitView
        }
        
        for passthroughView in passthroughViews {
            let hitPoint = convert(point, to: passthroughView)
            if let passthroughHitView = passthroughView.hitTest(hitPoint, with: event) {
                return passthroughHitView
            }
        }
        return self
    }
}
