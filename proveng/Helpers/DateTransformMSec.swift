//
//  DateTransformMSec.swift
//  proveng
//
//  Created by Dmitry Kulakov on 25.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import ObjectMapper

open class DateTransformMSeconds: TransformType {

    public typealias Object = Date
    public typealias JSON = Double
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> Date? {
        if let timeInt = value as? Double {
            let dateFromServer = Date(timeIntervalSince1970: TimeInterval(timeInt/1000))
            return dateFromServer
        }
        
        if let timeStr = value as? String {
            let dateFromServer = Date(timeIntervalSince1970: TimeInterval(atof(timeStr)/1000))
            return dateFromServer
        }
        
        return nil
    }
    
    open func transformToJSON(_ value: Date?) -> Double? {
        if let date = value {
            let doubleData = Double(date.timeIntervalSince1970)*1000
            return doubleData.truncate(places: 0)
        }
        return nil
    }
}
