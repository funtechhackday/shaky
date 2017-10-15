//
//  UIColor+MyAppColor.swift
//  ShakeIt
//
//  Created by Denis Karpenko on 18.02.16.
//  Copyright © 2016 Denis Karpenko. All rights reserved.
//

import Foundation
import UIKit
extension UIColor {
    class func appColor() -> UIColor {
        return UIColor(red: 69.0/255.0, green: 171.0/255.0, blue:
            255.0/255.0, alpha: 1)
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
}

//func delay(delay:Double, closure:()->()) {
//    dispatch_after(
//        dispatch_time(
//            DISPATCH_TIME_NOW,
//            Int64(delay * Double(NSEC_PER_SEC))
//        ),
//        dispatch_get_main_queue(), closure)
//}
