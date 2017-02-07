//
//  EventTypes.swift
//  proveng
//
//  Created by Dmitry Kulakov on 29.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import UIKit


@objc public enum EventType: Int {
    case workshop
    case lesson
    case material
    case test
    case cancelled
    case accepted
    case unknown
    
    public var rawValue: String {
        switch self {
        case .workshop:
            return "Workshop"
        case .lesson:
            return "Lesson"
        case .material:
            return "Material"
        case .test:
            return "Test"
        case .accepted:
            return "Accepted"
        case .cancelled:
            return "Denied"
        case .unknown:
            return "Unknown"
        }
    }
    
    public init(rawValue: String) {
        switch rawValue {
        case "Workshop":
            self = .workshop
        case "Lesson":
            self = .lesson
        case "Material":
            self = .material
        case "Test":
            self = .test
        case "Accepted":
            self = .accepted
        case "Denied":
            self = .cancelled
        case "Unknown":
            self = .unknown
        default:
            self = .unknown
        }
    }
}

@objc public enum FeedButtonType: Int {
    case denied
    case accepted
}



