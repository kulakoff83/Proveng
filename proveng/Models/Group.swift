//
//  Group.swift
//  proveng
//
//  Created by Виктория Мацкевич on 03.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class Group: GroupPreview {
    
    var members = List<UserPreview>()
    dynamic var leader: UserPreview!
    var scheduleEvents = List<EventPreview>()
    dynamic var lifetimeEvent: EventPreview? = nil
    
    override class func objectForMapping(map: Map) -> BaseMappable? {
        return Group()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        if let context = map.context as? ContextType{
            switch context {
            case .write:
                let firstContext = map.context
                map.context = ContextType.short
                members     <- (map["members"], ArrayTransform<UserPreview>(context: map.context))
                leader      <- map["leader"]
                map.context = firstContext
            case .short:
                break
            }
        } else {
            members     <- (map["members"], ArrayTransform<UserPreview>())
            leader      <- map["leader"]
        }
    }
}
