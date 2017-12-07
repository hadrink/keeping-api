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

    /**
     TODO: TEST.
     Service to subscribe a user to a community.
     - parameter username: Unique username.
     - parameter communityName: Unique communityName
     */
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

    /**
     TODO: TEST.
     Get communities by subscriber.
     - parameter subscriber: Unique username.
     - returns: A list of community documents.
     */
    public static func getCommnunitiesBy(subscriber username: String) throws -> Document {
        let projection: Projection = ["_id": .excluded, "subscribers": .excluded]
        do {
            return try collection.find("subscribers" == username, projecting: projection).makeDocument()
        } catch let e {
            print("Get communities error \(e)")
            throw ServicesErrors.getCommunities
        }
    }
}
