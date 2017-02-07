//
//  TestCard.swift
//  proveng
//
//  Created by Виктория Мацкевич on 22.09.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class TestCard: BaseModel{
    
    dynamic var question: String? = nil
    dynamic var answer: TestAnswer? = nil
    var testAnswers = List<TestAnswer>()
    
    override class func objectForMapping(map: Map) -> BaseMappable? {
        return TestCard()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        if let context = map.context as? ContextType{
            switch context {
            case .write:
                var testCard = Mapper<TestCard>(context: ContextType.short).toJSON(self)
                testCard <- map["testCard"]
                BaseModel.realmWrite {
                    answer <- map["testAnswer"]
                }
            case .short:
                var id = self.objectID
                id <- map["id"]
            }
        } else {
            question      <- map["question"]
            testAnswers   <- (map["testAnswers"], ArrayTransform<TestAnswer>())
        }
    }
}
