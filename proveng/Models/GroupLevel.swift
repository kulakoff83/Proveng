//
//  GroupLevel.swift
//  proveng
//
//  Created by Виктория Мацкевич on 28.09.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class GroupLevel: GroupLevelPreview{
    dynamic var count: Int = 0
    
    override class func objectForMapping(map: Map) -> BaseMappable? {
        return GroupLevel()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        count   <- map["count"]
    }
}
