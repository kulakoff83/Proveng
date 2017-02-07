//
//  MapperExtensions.swift
//  proveng
//
//  Created by Dmitry Kulakov on 07.09.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import PromiseKit

extension Mapper {
    
    func mapArrayPromise<T: StaticMappable>(_ data: [AnyObject]) -> Promise<[T]> {
        guard let objects = Mapper<T>().mapArray(JSONObject: data) else {
            return Promise(error: ApiError(code: 048, userInfo: [NSLocalizedDescriptionKey as NSObject:"Write to storage error" as AnyObject]))
        }
        return Promise(value: objects)
    }
    
    func mapPromise<T: StaticMappable>(_ data: [String: AnyObject]) -> Promise<T> {
        guard let object = Mapper<T>().map(JSON: data) else {
            return Promise(error: ApiError(code: 048, userInfo: [NSLocalizedDescriptionKey as NSObject:"Write to storage error" as AnyObject]))
        }
        return Promise(value: object)
    }
    
    func getJsonStringFromOblect<T: StaticMappable>(_ data: T) -> String {
        var objectJSON : String?
        objectJSON = Mapper<T>(context: ContextType.write).toJSONString(data)
        print("JSONString to Backend \(objectJSON)")
        if let JSON = objectJSON {
            return JSON
        } else {
            return ""
        }
    }
    
    func getJsonStringFromArray<T: StaticMappable>(_ data: [T]) -> String{
        var objectJSON : String?
        objectJSON = Mapper<T>(context: ContextType.write).toJSONString(data)
        print("JSONString to Backend \(objectJSON)")
        if let JSON = objectJSON {
            return JSON
        } else {
            return ""
        }
    }
}
