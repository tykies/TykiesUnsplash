//
//  Extensions.swift
//  UnsplashKit
//
//  Created by susuyan on 2017/11/9.
//  Copyright © 2017年 susuyan. All rights reserved.
//

import UIKit
import Foundation

extension URL {
    var queryPairs : [String : String] {
        var results = [String: String]()
        let pairs  = self.query?.components(separatedBy: "&") ?? []
                
        for pair in pairs {
            let kv = pair.components(separatedBy: "=")
            results.updateValue(kv[1], forKey: kv[0])
        }
        return results
    }
}


extension UIColor {
    static func colorWithHexString(_ hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
