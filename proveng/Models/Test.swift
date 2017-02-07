//
//  Test.swift
//  proveng
//
//  Created by Виктория Мацкевич on 22.09.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class Test: TestPreview{
    
    var cards = List<TestCard>()
    dynamic var mark: Int = 0
    dynamic var resultLevel: String? = nil
    
    override class func objectForMapping(map: Map) -> BaseMappable? {
        return Test()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        cards     <- (map["testCards"], ArrayTransform<TestCard>())
        mark      <- map["mark"]
        resultLevel      <- map["level"]
    }
}
