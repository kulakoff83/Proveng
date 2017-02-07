//
//  File.swift
//  proveng
//
//  Created by Виктория Мацкевич on 08.11.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class EventGroup: GroupPreview {
    
    override class func objectForMapping(map: Map) -> BaseMappable? {
        return EventGroup()
    }
}
