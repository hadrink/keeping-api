//
//  CommunityServices.swift
//  KeepinServices
//
//  Created by Rplay on 20/11/2017.
//

import Foundation
import MongoKitten

/// Community services.
public struct CommunityServices: Services {
    static let db = try! KIEnvironment.prod.database()
    static var collection = db[KICollections.communities.rawValue]

    public static func subscribe(username: String, to communityName: String) throws {
        do {
            try collection.update("name" == communityName, to: [
                "$addToSet": [
                    "subscribers": username
                ]
            ])
        } catch let e {
            print("Subscription error: \(e)")
            throw ServicesErrors.subscribe
        }
    }
}
