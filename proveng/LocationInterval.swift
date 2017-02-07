//
//  LocationInterval.swift
//  proveng
//
//  Created by Виктория Мацкевич on 09.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import Eureka

enum LocationInterval : String, CustomStringConvertible {
    case Atlanta = "Atlanta"
    case Copnhagen = "Copnhagen"
    case Detroit = "Detroit"
    case Florida = "Florida"
    case Georgtown = "Georgtown"
    case London = "London"
    case Madrid = "Madrid"
    
    var description : String { return rawValue }
    
    static let allValues = [Atlanta, Copnhagen, Detroit, Florida, Georgtown, London, Madrid]
}