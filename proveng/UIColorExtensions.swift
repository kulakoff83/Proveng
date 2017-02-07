//
//  UIColorExtensions.swift
//  proveng
//
//  Created by Dmitry Kulakov on 12.10.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    func toImage() -> UIImage {
        let rect = CGRect(x:0, y:0, width:1, height:1)
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        self.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    class func bgFromFeedCell() -> UIColor {
        return ColorForElements.background.color
    }
    
    class func mainFromFeedCell() -> UIColor {
        return ColorForElements.main.color
    }
    
    class func additionalFromFeedCell() -> UIColor {
        return ColorForElements.additional.color
    }
    
    class func textFromFeedCell() -> UIColor {
        return ColorForElements.text.color
    }
}
