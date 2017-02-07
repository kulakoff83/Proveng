//
//  Extensions.swift
//  proveng
//
//  Created by Dmitry Kulakov on 25.07.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import AlamofireImage

extension UIImage {
    
    class func createImageFromTabIcon() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 25, height: 25)
        let color = UIColor.gray
        let image = UIImage.createImage(rect: rect, color: color)
        return image
    }
    
    class func createImageFromNavBar() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let color = UIColor.clear
        let image = UIImage.createImage(rect: rect, color: color)
        return image
    }
    
    class func createImage(rect: CGRect, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    class func checkImage(named: String) -> UIImage{
        if let image = UIImage(named: named) {
            return image
        } else {
            return UIImage.createImageFromTabIcon()
        }
    }
}

extension UIImageView {
     @discardableResult func requestImage(_ imageUrl: URL) -> UIImageView {
        let filter = AspectScaledToFillSizeWithRoundedCornersFilter(
            size: self.frame.size,
            radius: self.frame.height / 2.0
        )
        self.af_setImage(withURL: imageUrl, placeholderImage: IconForElements.noPhoto.icon, filter: filter) 
        return self
    }
}

extension UIImageView {
    @discardableResult func requestOriginalImage(_ imageUrl: URL) -> UIImageView {
        self.af_setImage(withURL: imageUrl, placeholderImage: IconForElements.noPhoto.icon)
        return self
    }
}

extension String {  
    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters as CharacterSet)
    }
    
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
}

extension UIViewController {
    func chekInternetConnection() -> Bool {
        guard Reachability.isConnectedToNetwork() else {
            let operation = RouterOperationAlert.showError(title: Constants.ErrorAlertTitle, message: Constants.LostInternetConectionAlertMessage, handler: nil)
            self.router.performOperation(operation)
            return false
        }
        return true
    }
}

extension UINavigationController {
    open override var shouldAutorotate : Bool {
        return visibleViewController!.shouldAutorotate
    }
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return (visibleViewController?.supportedInterfaceOrientations)!
    }
}

extension UIAlertController {
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    open override var shouldAutorotate : Bool {
        return false
    }
}

//extension Int {
//    static func getEventDuration(_ firstDate: Date, secondDate: Date) -> Int{
//        let calendar: Calendar = Calendar.current
//        let date1 = calendar.startOfDay(for: firstDate)
//        let date2 = calendar.startOfDay(for: secondDate)
//        
//        let flags = NSCalendar.Unit.month
//        let components = (calendar as NSCalendar).components(flags, from: date1, to: date2, options: [])
//        return components.day!
//    }
//}

extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}

extension Dictionary {
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).stringByAddingPercentEncodingForURLQueryValue()!
            let stringValue = String(describing: value)
            let percentEscapedValue = stringValue.stringByAddingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        return parameterArray.joined(separator: "&")
    }
}
