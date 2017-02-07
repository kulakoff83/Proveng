//
//  EventExtensions.swift
//  proveng
//
//  Created by Dmitry Kulakov on 21.10.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation

extension Event {
    
    class func iconByType(eventType: EventType) -> UIImage {
        switch eventType {
        case .workshop:
            return IconForElements.workshopIcon.icon
        case .lesson:
            return IconForElements.lessonIcon.icon
        case .material:
            return IconForElements.linkIcon.icon
        case .test:
            return IconForElements.challengeIcon.icon
        default:
            return UIImage.createImageFromTabIcon()
        }
        
    }
    
    class func colorByType(eventType: EventType) -> UIColor {
        switch eventType {
        case .workshop:
            return ColorForElements.main.color
        case .lesson:
            return ColorForElements.lesson.color
        case .material:
            return UIColor(hexString: "#1f303d")
        case .test:
            return UIColor(hexString: "#ffa400")
        case .accepted:
            return UIColor(hexString: "#7fc830")
        case .cancelled:
            return UIColor(hexString: "#d23030")
        default:
            return UIColor.clear
        }
    }
    
    func containsEventBy(type: EventType) -> Bool {
        let filteredArray = self.events.filter(){$0.type == type.rawValue}
        if filteredArray.count > 0 {
            return true
        }
        return false
    }
}
