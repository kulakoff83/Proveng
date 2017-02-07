//
//  TestAnswer.swift
//  proveng
//
//  Created by Виктория Мацкевич on 22.09.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class TestAnswer: BaseModel{
    
    dynamic var text: String? = nil
    
    override class func objectForMapping(map: Map) -> BaseMappable? {
        return TestAnswer()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        if map.mappingType == .fromJSON {
            text  <- map["text"]
        }
    }
}
