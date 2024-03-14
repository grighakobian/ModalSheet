//
//  DropShadowView.swift
//  TBC ipad
//
//  Created by Grigor Hakobyan on 03.02.22.
//  Copyright © 2022 TBC. All rights reserved.
//

import UIKit

final class DropShadowView: UIView {

    override var clipsToBounds: Bool {
        get { return false }
        set { super.clipsToBounds = false }
    }

    override class var layerClass: AnyClass {
        return DropShadowLayer.self
    }

//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        addDropShadow()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        
//        addDropShadow()
//    }
//
//    private func addDropShadow() {
//        clipsToBounds = false
//        layer.masksToBounds = false
//        
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOffset = CGSize(width: 0, height: 0)
//        layer.shadowOpacity = 0.1
//        layer.shadowRadius = 3.0
//    }
}

final class DropShadowLayer: CALayer {

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

// MARK: - Internal accessor

extension UIView {
    var parentDropShadowView: DropShadowView? {
        var superview = self.superview
        while let _superview = superview {
            if let dropShadowView = _superview as? DropShadowView {
                return dropShadowView
            }
            superview = _superview.superview
        }
        return nil
    }
}
