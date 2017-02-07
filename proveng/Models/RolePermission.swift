//
//  RolePermission.swift
//  proveng
//
//  Created by Виктория Мацкевич on 25.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class RolePermission: BaseModel {
    
    dynamic var name: String? = nil
    dynamic var hasAccessFlag: String? = nil
    dynamic var object: String? = nil
    
    override class func objectForMapping(map: Map) -> BaseMappable? {
        return RolePermission()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        name          <- map["name"]
        hasAccessFlag <- map["accessFlag"]
        object        <- map["object"]
    }
}
