//
//  Materials.swift
//  proveng
//
//  Created by Виктория Мацкевич on 22.09.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class Material: MaterialPreview{
    
    dynamic var materialDescript: String? = nil
    
    override class func objectForMapping(map: Map) -> BaseMappable? {
        return Material()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        materialDescript  <- map["description"]

    }
}
