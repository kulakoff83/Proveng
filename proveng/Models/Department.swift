//
//  Department.swift
//  proveng
//
//  Created by Виктория Мацкевич on 25.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class Department: BaseModel {
    
    dynamic var url: String? = nil
    dynamic var name: String? = nil
    
    override class func objectForMapping(map: Map) -> BaseMappable? {
        return Department()
    }    
    override func mapping(map: Map) {
        super.mapping(map: map)
        if let context = map.context as? ContextType{
            switch context {
            case .write:
                url          <- map["url"]
                name         <- map["name"]
            case .short:
                break
            }
        } else {
            url           <- map["url"]
            name          <- map["name"]
        }
    }
}
