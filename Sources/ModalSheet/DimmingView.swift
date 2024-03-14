import UIKit

final class DimmingView: UIView {

    override var backgroundColor: UIColor? {
        get { return UIColor.dimmBackground  }
        set { super.backgroundColor = UIColor.dimmBackground }
    }
}
