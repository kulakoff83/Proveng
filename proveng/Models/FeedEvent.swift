//
//  FeedEvent.swift
//  proveng
//
//  Created by Dmitry Kulakov on 25.10.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class FeedEvent: Event {
    
    dynamic var testItem: Test? = nil
    dynamic var materialItem: Material? = nil
    dynamic var leaderID: Int = 0
    dynamic var leaderName: String = ""
    dynamic var leaderImageURL: String = ""
    override class func objectForMapping(map: Map) -> BaseMappable? {
        return FeedEvent()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        leaderID <- map["leader"]
        switch self.typeEnum {
        case .test:
            testItem <- map["eventableItem"]
        case .material:
            materialItem  <- map["eventableItem"]
        default:
            break
        }
    }
}

