//
//  ServiceForBasicValue.swift
//  proveng
//
//  Created by Dmitry Kulakov on 11.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation

class ServiceForBasicValue {
    
    static let sharedInstance = ServiceForBasicValue()
    
    func getGroupDuration() -> [String] {
        return ["1 month", "2 months", "3 months", "4 months", "5 months", "6 months"]
    }
    func getGroupLocation() -> [String] {
        return ["China, Tower", "San Diego, USA", "Chicago, USA", "Oxford, UK", "Cardiff, UK", "Cambridge, UK"]
    }
    
    func getRepeatInterval() -> [String] {
        return ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    }
    
    func getMaterialType() -> [String] {
        return ["Link", "Audio", "Video"]
    }
    
    func getCalendarEventsType() -> [String] {
        return ["Lesson", "Workshop"]
    }
    
    func getDepartment() -> [String] {
        return ["Admin Department", "Administration", "Corporate support", "cPrime", "Determine", "eCommerce", "Education", "Finance Department", "HR", "IT Department", "Kazan", "Legal Department", "LiveNation", "Marketing", "Men`s Wearhouse", "Minted", "Mobile studio", "ModelN", "NOC", "PR", "PIX"]
    }
    func getReasonsForDeletion() -> [String] {
        return ["End of cooperation", "Work load", "Family reasons", "Poor attendance", "Other reasons"]
    }
    func getReasonsForNotAttending() -> [String] {
        return ["I'm sick", "Personal reason", "It's work related", "I have another meeting"]
    }
    
    func getGroupLevels() -> [String] {
        return ["Elementary","Pre-intermediate","Intermediate","Upper-intermediate"]
    }

    func getlevelColorTags() -> [String:UIColor] {
    return ["Beginner": UIColor.purple,"Elementary": UIColor(hexString: "#88d6a2"),"Pre-Intermediate": UIColor(hexString: "#88a3d6"),"Intermediate": UIColor(hexString: "#a288d6"),"Upper-Intermediate": UIColor(hexString: "#e2939a"), "Advanced": UIColor.brown, "Proficient": UIColor.cyan]
    }
}
