import UIKit

final class DropShadowView: UIView {

    override var clipsToBounds: Bool {
        get { return false }
        set { super.clipsToBounds = false }
    }

    override class var layerClass: AnyClass {
        return DropShadowLayer.self
    }
}

private final class DropShadowLayer: CALayer {

    override var masksToBounds: Bool {
        get { return false }
        set { super.masksToBounds = false }
    }

    override var shadowColor: CGColor? {
        get { return UIColor.black.cgColor }
        set { super.shadowColor = UIColor.black.cgColor  }
    }

    override var shadowOffset: CGSize {
        get { return CGSize(width: 0, height: 0) }
        set { super.shadowOffset = CGSize(width: 0, height: 0) }
    }

    override var shadowOpacity: Float {
        get { return 0.1 }
        set { super.shadowOpacity = 0.1 }
    }

    override var shadowRadius: CGFloat {
        get { return 3.0 }
        set { super.shadowRadius = 3.0 }
    }
}

extension UIView {

    var parentDropShadowView: DropShadowView? {
        var parent = superview
        while let superview = parent {
            if let dropShadowView = superview as? DropShadowView {
                return dropShadowView
            }
            parent = superview.superview
        }
        return nil
    }

    var heightConstraint: NSLayoutConstraint? {
        for constraint in constraints {
            if constraint.firstAttribute == .height && constraint.secondAttribute == .notAnAttribute {
                return constraint
            }
        }
        return nil
    }
}
