//
//  MapperPromise.swift
//  proveng
//
//  Created by Dmitry Kulakov on 31.08.16.
//  Copyright © 2016 Provectus. All rights reserved.
//

import Foundation
import ObjectMapper
import PromiseKit
import RealmSwift

class MapperPromise<T:Object> where T:StaticMappable {
    
    func mapFromJSONPromise(_ JSON: [String: AnyObject]) -> Promise<T> {
        return Promise { fulfill, reject in
            guard let object = Mapper<T>().map(JSON: JSON) else {
                    let error = ApiError(errorDescription: "Error in mapFromJSONPromise")
                    reject(error)
                    return
            }
            fulfill(object)
        }
    }
    
    func mapToJsonPromise(_ data: T, context: MapContext?) -> Promise<[String : AnyObject]> {
        return Promise { fulfill, reject in
            BaseModel.realmWrite {
                let objectJSON =  Mapper<T>(context: context).toJSON(data)
                fulfill(objectJSON as [String : AnyObject])
            }
        }
    }
    
    func mapToJsonPromiseWithoutContext(_ data: T) -> Promise<[String : AnyObject]> {
        return Promise { fulfill, reject in
            BaseModel.realmWrite {
                let objectJSON =  Mapper<T>().toJSON(data)
                fulfill(objectJSON as [String : AnyObject])
            }
        }
    }
}


