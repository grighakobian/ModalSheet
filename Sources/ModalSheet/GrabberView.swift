import UIKit

final class GrabberView: UIView {

    override var backgroundColor: UIColor? {
        get { return UIColor.grabberBackground  }
        set { super.backgroundColor = UIColor.grabberBackground }
    }

//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        backgroundColor = UIColor.grabberBackground
//    }
//    
//    public required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        
//        backgroundColor = UIColor.grabberBackground
//    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height / 2.0
    }
}
