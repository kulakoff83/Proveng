//
//  BaseModel.swift
//  proveng
//
//  Created by Виктория Мацкевич on 27.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import PromiseKit
import Realm


class BaseModel: Object, StaticMappable {
    
    dynamic var modifyDate: Date? = nil
    dynamic var objectID: Int = 0
    
    
    class func objectForMapping(map: Map) -> BaseMappable? {
        return BaseModel()
    }
    
    override class func primaryKey() -> String? {
        return "objectID"
    }
    
    func mapping(map: Map) {
        if map.mappingType == .toJSON {
            if self is TestCard {
                return
            }
            var id = self.objectID
            id <- map[primaryJSONKey]
        } else {
            self.objectID <- map[primaryJSONKey]
        }
        modifyDate     <- map["modifyDtm"]
    }
    
    var primaryJSONKey: String {
        return "id"
    }
}

extension BaseModel {
    
    @discardableResult static func realmWrite(_ handler: () -> Void) -> Promise<String> {
        return Promise { fulfill, reject in
            let realm = RLMRealm.default()
            realm.beginWriteTransaction()
            handler()
            do {
                try realm.commitWriteTransaction()
                fulfill("Success")
            } catch (let error) {
                print("Realm Commit Write ERROR : \(error)")
                reject(ApiError(errorDescription:"Realm Commit Write ERROR"))
            }
        }
    }
    
    @discardableResult static func objectRealmWrite(realm: Realm?, handler: @escaping () -> Void) -> Promise<String> {
        return Promise { fulfill, reject in
            do {
                try realm?.write() {
                    handler()
                }
                fulfill("Success")
            } catch {
                reject(ApiError(errorDescription:"Realm Commit Write ERROR"))
            }
        }
    }
    
    static func mappedCopy<T:Object>(_ object: T, context: Bool = true) -> Promise<T> where T:StaticMappable {
        return firstly {
            if context {
                return MapperPromise<T>().mapToJsonPromise(object, context: ContextType.write)
            } else  {
                return MapperPromise<T>().mapToJsonPromiseWithoutContext(object)
            }
        }.then { JSON -> Promise<T> in
            return MapperPromise<T>().mapFromJSONPromise(JSON as [String : AnyObject])
        }
    }
}

