//
//  File.swift
//  proveng
//
//  Created by Виктория Мацкевич on 03.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class UserPreview: BaseModel {
    
    dynamic var firstName: String? = nil
    dynamic var lastName: String? = nil
    dynamic var imageURL: String? = nil
    var dayBook = List<DayBook>()
    
    override class func objectForMapping(map: Map) -> BaseMappable? {
        return UserPreview()
    }
    
    override func mapping(map: Map) {
        if let context = map.context as? ContextType{
            switch context {
            case .short:
                var id = self.objectID
                id <- map["id"]
            default:
                super.mapping(map: map)
                firstName  <- map["firstName"]
                lastName   <- map["lastName"]
                imageURL   <- map["url"]
                dayBook    <- (map["dayBooks"], ArrayTransform<DayBook>())
            }
        } else {
            super.mapping(map: map)
            firstName  <- map["firstName"]
            lastName   <- map["lastName"]
            imageURL   <- map["url"]
            dayBook    <- (map["dayBooks"], ArrayTransform<DayBook>())
        }        
    }
}
