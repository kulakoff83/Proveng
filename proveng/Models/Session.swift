//
//  Session.swift
//  proveng
//
//  Created by Виктория Мацкевич on 29.07.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class Session: BaseModel {
    
    dynamic var userID: Int = 0
    dynamic var token: String? = nil
    dynamic var currentUser: User? = nil
    
    override class func objectForMapping(map: Map) -> BaseMappable? {
        return Session()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        token     <- map["token"]
        userID    <- map["userId"]
        objectID = userID
    }
}
