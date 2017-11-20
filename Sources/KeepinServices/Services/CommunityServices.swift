//
//  CommunityServices.swift
//  KeepinServices
//
//  Created by Rplay on 20/11/2017.
//

import Foundation
import MongoKitten

/// Community services.
struct CommunityServices: Services {
    static let db = try! KIEnvironment.prod.database()
    static var collection = db[KICollections.communities.rawValue]

    /**
     TODO: TEST.
     Get community by name.
     - parameter name: The community name (String).
     - parameter excludedKeys: Keys not to go up (Projection?)
     */
    static func getCommunityBy(
        name: String,
        excludedKeys: Projection? = ["_id": .excluded]
    ) throws -> Document? {
        do {
            guard let key = excludedKeys else {
                return try collection.findOne("name" == name)
            }

            return try collection.findOne("name" == name, projecting: key)
        } catch let e {
            print("Get community by name error: \(e)")
            throw ServicesErrors.getCommunityFailed
        }
    }
}
