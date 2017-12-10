//
//  UsersServices.swift
//  KeepinServices
//
//  Created by Rplay on 01/10/2017.
//
import MongoKitten
import Foundation

/// Users Services.
public struct UsersServices: Services {
    static let db = try! KIEnvironment.prod.database()
    static var collection = db[KICollections.users.rawValue]

    /**
     TODO: TEST.
     Service to subscribe a user to a community.
     - parameter username: Unique username.
     - parameter communityName: Unique communityName
     */
    public static func subscribe(username: String, to communityName: String) throws {
        do {
            let c = try CommunityServices.read(by: "name", value: communityName, projection: nil)
            try collection.update("username" == username, to: [
                "$addToSet": [
                    "subscriptions": c
                ]
            ])
        } catch let e {
            print("Subscription error: \(e)")
            throw ServicesErrors.subscribe
        }
    }


    /**
     TODO: TEST.
     Get subscriptions.
     - parameter username: Unique username.
     - returns: A list of community documents.
     */
    public static func getSubscriptions(from username: String) throws -> Document? {
        do {
            let projection: Projection = [
                "_id": .excluded,
                "password": .excluded,
                "subscriptions._id": .excluded,
            ]

            return try self.read(by: "username", value: username, projection: projection)
        } catch let e {
            print("Get communities error \(e)")
            throw ServicesErrors.getCommunities
        }
    }
}
