//
//  File.swift
//  proveng
//
//  Created by Виктория Мацкевич on 29.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class Location: BaseModel {
    
    dynamic var name: String? = nil
    dynamic var place: String? = nil
    dynamic var roominess: String? = nil
    
    override class func objectForMapping(map: Map) -> BaseMappable? {
        return Location()
    }
    
    override func mapping(map: Map) {        
        if let context = map.context as? ContextType{
            switch context {
            case .short:
                var id = self.objectID
                id <- map["id"]
            default:
                super.mapping(map: map)
                name       <- map["name"]
                place      <- map["place"]
                roominess  <- map["roominess"]
            }
        } else {
            super.mapping(map: map)
            name   <- map["name"]
            place      <- map["place"]
            roominess  <- map["roominess"]
        }
    }
}
