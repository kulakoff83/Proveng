//
//  User.swift
//  proveng
//
//  Created by Dmitry Kulakov on 15.07.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper

class User: UserPreview {
    
    dynamic var loginName: String? = nil
    dynamic var email: String? = nil
    dynamic var phone: String? = nil
    dynamic var skype: String? = nil
    dynamic var inviteDate: Date? = nil
    var groups = List<GroupPreview>()
    dynamic var level: String? = nil
    var role = List<Role>()
    dynamic var department: Department!
    
    override class func objectForMapping(map: Map) -> BaseMappable? {
        return User()
    }
    
    override func mapping(map: Map) {        
        if let context = map.context as? ContextType{
            switch context {
            case .write:
                phone        <- map["phone"]
                skype        <- map["skype"]
                let firstContext = map.context
                map.context = ContextType.short
                if department == nil || department.objectID == 0 {
                } else {
                    department   <- map["department"]
                }
                map.context = firstContext                
            case .short:
                super.mapping(map: map)
            }
        } else {
            super.mapping(map: map)
            loginName    <- map["loginName"]
            email        <- map["email"]
            phone        <- map["phone"]
            skype        <- map["skype"]
            inviteDate   <- (map["inviteDate"], DateTransformMSeconds())
            role         <- (map["roles"], ArrayTransform<Role>())
            department   <- map["department"]
            groups       <- (map["groups"], ArrayTransform<GroupPreview>())
            level        <- map["level"]
        }
    }
}

extension User {
    func userIsTeacher() -> Bool {
        let teacherRole = self.role.filter{ $0.name == "Teacher" }
        let adminRole = self.role.filter{ $0.name == "Administrator" }
        return (teacherRole.count > 0 || adminRole.count > 0) ? true : false
    }
}

enum UserRoleType: String {
    case guest = "Guest"
    case student = "Student"
    case teacher = "Teacher"
}

