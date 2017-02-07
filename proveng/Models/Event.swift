//
//  Event.swift
//  proveng
//
//  Created by Виктория Мацкевич on 08.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class Event: EventPreview {
    
    dynamic var eventName: String? = nil
    dynamic var leader: UserPreview? = nil
    
    dynamic var group: EventGroup? = nil
    dynamic var superEventID: Int = 0
    dynamic var note: String? = nil
    var members = List<UserPreview>()
    var eventsB = List<EventPreview>()
    var events: [EventPreview] {
        get {
            return Array(eventsB)
        }
    }
    dynamic var dayStart: Date? = nil
    
    override class func objectForMapping(map: Map) -> BaseMappable? {
        return Event()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        if let context = map.context as? ContextType {
            switch context {
            case .write:
                eventName    <- map["name"]
                let firstContext = map.context
                map.context = ContextType.short
                leader       <- map["leader"]
                group        <- map["group"]
                map.context = firstContext
                note         <- map["note"]
            default:
                eventName    <- map["name"]
                leader       <- map["leader"]
                group        <- map["group"]
                superEventID <- map["superEvent_id"]
                note         <- map["note"]
                eventsB      <- (map["childEvents"], ArrayTransform<EventPreview>())
                if let startDate = self.dateStart {
                    self.dayStart = startDate.dateByDefaultTime(0, minute: 0, seconds: 0)
                }
            }
        } else {
            eventName    <- map["name"]
            leader       <- map["leader"]
            group        <- map["group"]
            superEventID <- map["superEvent_id"]
            note         <- map["note"]
            eventsB      <- (map["childEvents"], ArrayTransform<EventPreview>())
            if let startDate = self.dateStart {
                self.dayStart = startDate.dateByDefaultTime(0, minute: 0, seconds: 0)
            }
        }
    }
}

enum ContextType: MapContext {
    case write
    case short
}

