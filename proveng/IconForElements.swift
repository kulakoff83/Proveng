//
//  IconForElements.swift
//  proveng
//
//  Created by Виктория Мацкевич on 09.10.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation

public enum IconForElements {
    case calendar
    case groups
    case materials
    case profile
    case feed
    case settings
    case lesson
    case workshop
    case lessonIcon
    case workshopIcon
    case challengeIcon
    case link
    case linkIcon
    case groupName
    case groupLevel
    case eventName
    case location
    case time
    case notes
    case date
    case regular
    case addStudent
    case numOfStudent    
    case userLevel
    case points
    case name
    case email
    case skype
    case phone
    case department
    case about
    case support
    case terms
    case privacy
    case logout
    case duration
    case checkmark
    case noPhoto
    case shareMaterials
    case tabBarCalendarItem
    case tabBarGroupsItem
    case tabBarMaterialsItem
    case tabBarSettingsItem
    case tabBarProfileItem
    case tabBarFeedItem
    case loginBackground
    case login
    case testResult
    case startTest
    case otherTest
    case materialTitle
    case materialType
    case materialDescript
    case emptyFeed
    case profileBackground
    case profileAddBackground
    
    public var icon: UIImage {
        switch self {
        case .calendar:
            return UIImage.checkImage(named: "calendar")
        case .groups:
            return UIImage.checkImage(named: "groups")
        case .materials:
            return UIImage.checkImage(named: "materials")
        case .profile:
            return UIImage.checkImage(named: "profile")
        case .settings:
            return UIImage.checkImage(named: "settings")
        case .lesson:
            return UIImage.checkImage(named: "lesson")
        case .workshop:
            return UIImage.checkImage(named: "workshop")
        case .lessonIcon:
            return UIImage.checkImage(named: "lessonIcon")
        case .workshopIcon:
            return UIImage.checkImage(named: "workshopIcon")
        case .challengeIcon:
            return UIImage.checkImage(named: "challengeIcon")
        case .link:
            return UIImage.checkImage(named: "material")
        case .linkIcon:
            return UIImage.checkImage(named: "materialIcon")
        case .groupName:
            return UIImage.checkImage(named: "groupName")
        case .groupLevel:
            return UIImage.checkImage(named: "groupLevel")
        case .eventName:
            return UIImage.checkImage(named: "eventName")
        case .duration:
            return UIImage.checkImage(named: "duration")
        case .location:
            return UIImage.checkImage(named: "location")
        case .time:
            return UIImage.checkImage(named: "time")
        case .notes:
            return UIImage.checkImage(named: "notes")
        case .date:
            return UIImage.checkImage(named: "date")
        case .regular:
            return UIImage.checkImage(named: "repeat")
        case .addStudent:
            return UIImage.checkImage(named: "addStudents")
        case .numOfStudent:
            return UIImage.checkImage(named: "numStudent")
        case .userLevel:
            return UIImage.checkImage(named: "userLevel")
        case .points:
            return UIImage.checkImage(named: "points")
        case .email:
            return UIImage.checkImage(named: "email")
        case .skype:
            return UIImage.checkImage(named: "skype")
        case .phone:
            return UIImage.checkImage(named: "phone")
        case .department:
            return UIImage.checkImage(named: "department")
        case .about:
            return UIImage.checkImage(named: "about")
        case .support:
            return UIImage.checkImage(named: "support")
        case .terms:
            return UIImage.checkImage(named: "terms")
        case .privacy:
            return UIImage.checkImage(named: "privacy")
        case .logout:
            return UIImage.checkImage(named: "logout")
        case .checkmark:
            return UIImage.checkImage(named: "checkmark")
        case .noPhoto:
            return UIImage.checkImage(named: "noPhoto")
        case .materialTitle:
            return UIImage.checkImage(named: "materialTitle")
        case .materialType:
            return UIImage.checkImage(named: "materialType")
        case .materialDescript:
            return UIImage.checkImage(named: "materialDesc")
        case .shareMaterials:
            return UIImage.checkImage(named: "shareMaterials")
        case .tabBarCalendarItem:
            return UIImage.checkImage(named: "calendar")
        case .tabBarGroupsItem:
            return UIImage.checkImage(named: "groups")
        case .tabBarMaterialsItem:
            return UIImage.checkImage(named: "materials")
        case .tabBarSettingsItem:
            return UIImage.checkImage(named: "settings")
        case .tabBarProfileItem:
            return UIImage.checkImage(named: "profile")
        case .tabBarFeedItem:
            return UIImage.checkImage(named: "feed")
        default:
            return UIImage.createImageFromTabIcon()
        }
    }
    
    public var image: UIImage {
        switch self {
        case .loginBackground:
            return UIImage.checkImage(named: "sign_in_bg")
        case .login:
            return UIImage.checkImage(named: "groups")
        case .startTest:
            return UIImage.checkImage(named: "sign_in")
        case .otherTest:
            return UIImage.checkImage(named: "other_test")
        case .testResult:
            return UIImage.checkImage(named: "test_result")
        case .emptyFeed:
            return UIImage.checkImage(named: "empty_feed")
        case .profileBackground:
            if SessionData.teacher {
                return UIImage.checkImage(named: "tProfileBackground")
            } else {
                return UIImage.checkImage(named: "sProfileBackground")
            }
        case .profileAddBackground:
            if SessionData.teacher {
                return UIImage.checkImage(named: "tAddProfileBackground")
            } else {
                return UIImage.checkImage(named: "sAddProfileBackground")
            }
        default:
            return UIImage.createImageFromTabIcon()
        }
    }
}
