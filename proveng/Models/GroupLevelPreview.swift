//
//  GroupLevelPreview.swift
//  proveng
//
//  Created by Виктория Мацкевич on 30.10.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class GroupLevelPreview: BaseModel{
    
    dynamic var name: String? = nil
    dynamic var value: Int = 0
    
    override class func objectForMapping(map: Map) -> BaseMappable? {
        return GroupLevelPreview()
    }
    override class func primaryKey() -> String? {
        return "name"
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        name    <- map["name"]
        value   <- map["value"]
    }
}
