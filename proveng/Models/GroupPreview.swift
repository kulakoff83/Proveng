//
//  GroupPreview.swift
//  proveng
//
//  Created by Виктория Мацкевич on 25.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class GroupPreview: BaseModel {
    
    dynamic var groupName: String? = nil
    dynamic var groupLevel: String? = nil
    dynamic var primaryGroupFlag: Bool = false
    
    override class func objectForMapping(map: Map) -> BaseMappable? {
        return GroupPreview()
    }
    
    override func mapping(map: Map) {        
        if let context = map.context as? ContextType{
            switch context {
            case .short:
                var id = self.objectID
                id <- map["id"]
            default:
                super.mapping(map: map)
                groupName      <- map["name"]
                groupLevel     <- map["level"]
                primaryGroupFlag <- map["primaryGroupFlag"]
            }
        } else {
            super.mapping(map: map)
            groupName        <- map["name"]
            groupLevel       <- map["level"]
            primaryGroupFlag <- map["primaryGroupFlag"]
        }
    }
}
