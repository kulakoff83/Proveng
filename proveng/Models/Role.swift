//
//  Role.swift
//  proveng
//
//  Created by Виктория Мацкевич on 24.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//
import Foundation
import RealmSwift
import ObjectMapper

class Role: BaseModel {
    
    dynamic var name: String? = nil
    var permissions = List<RolePermission>()
    
    class func newInstance(_ map: Map) -> BaseMappable? {
        return Role()
    }
    
    override class func objectForMapping(map: Map) -> BaseMappable? {
        return Role()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        name          <- map["name"]
        permissions   <- (map["permissions"], ArrayTransform<RolePermission>())
    }
}
