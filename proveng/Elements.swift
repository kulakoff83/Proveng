//
//  ColorForElements.swift
//  proveng
//
//  Created by Dmitry Kulakov on 12.10.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation

public enum ColorForElements {
    case main
    case background
    case tabbar
    case text
    case additional
    case lesson
    case terms
    
    public var color: UIColor {
        switch self {
        case .main:
            if SessionData.teacher {
                return UIColor(hexString: "#0dc896")
            } else {
                return UIColor(hexString: "#00aae5")
            }
        case .background:
            if SessionData.teacher {
                return UIColor(hexString: "#eef5f4")
            } else {
                return UIColor(hexString: "#f2f5f8")
            }
        case .tabbar:
            if SessionData.teacher {
                return UIColor(hexString: "#8ca09c")
            } else {
                return UIColor(hexString: "#969ea6")
            }
        case .text:
            if SessionData.teacher {
                return UIColor(hexString: "#00372e")
            } else {
                return UIColor(hexString: "#1f303d")
            }
        case .additional:
            if SessionData.teacher {
                return UIColor(hexString: "#ff4e59")
            } else {
                return UIColor(hexString: "#ffa400")
            }
        case .lesson:
            if SessionData.teacher {
                return UIColor(hexString: "#e2939a")
            } else {
                return UIColor(hexString: "#e2939a")
            }
        case .terms:
            return UIColor(hexString: "#949fa8")
        }
    }
}
