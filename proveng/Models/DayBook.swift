//
//  DayBook.swift
//  proveng
//
//  Created by Виктория Мацкевич on 25.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class DayBook: BaseModel {
    
    dynamic var type: String? = nil
    dynamic var mark: Int = 0
    dynamic var markDate: Date? = nil
    
    class func newInstance(_ map: Map) -> BaseMappable? {
        return DayBook()
    }
    override class func objectForMapping(map: Map) -> BaseMappable? {
        return DayBook()
    }
        
    override func mapping(map: Map) {
        super.mapping(map: map)
        type          <- map["type"]
        mark          <- map["mark"]
        markDate      <- (map["markDate"], DateTransformMSeconds())
    }
}
