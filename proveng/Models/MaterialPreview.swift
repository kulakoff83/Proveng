//
//  MaterialPreview.swift
//  proveng
//
//  Created by Виктория Мацкевич on 20.10.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class MaterialPreview: BaseModel{
    
    dynamic var name: String? = nil
    dynamic var type: String? = nil
    dynamic var minLevel: String? = nil
    dynamic var link: String? = nil
    
    override class func objectForMapping(map: Map) -> BaseMappable? {
        return MaterialPreview()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        name      <- map["name"]
        minLevel  <- map["minLevel"]
        type      <- map["type"]
        link      <- map["link"]
    }
}
