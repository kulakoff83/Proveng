//
//  TestPreview.swift
//  proveng
//
//  Created by Виктория Мацкевич on 22.09.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class TestPreview: BaseModel{
    
    dynamic var name: String? = nil
    dynamic var type: String? = nil
    dynamic var duration: Date = Date(timeIntervalSince1970: 0)
    dynamic var weight: Int = 0
    dynamic var level: String? = nil
    dynamic var version: Double = 0.0
    
    override class func objectForMapping(map: Map) -> BaseMappable? {
        return TestPreview()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        if map.mappingType == .fromJSON {
            name       <- map["name"]
            duration   <- (map["duration"], DateTransformMSeconds())
            weight     <- map["weight"]
            level      <- map["minLevel"]
            version    <- map["version"]
            type       <- map["type"]
        }
    }
}
