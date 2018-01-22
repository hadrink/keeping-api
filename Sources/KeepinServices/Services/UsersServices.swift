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
    static let db = KIDatabase.db
    public static var collection = db[KICollections.users.rawValue]

    /**
     TODO: TEST.
     Service to subscribe a user to a community.
     - parameter username: Unique username.
     - parameter communityName: Unique communityName
     */
    public static func subscribe(usernameId: String, to communityNameId: String) throws {
        do {
            let c: Document? = try CommunityServices.readOne(by: "name_id", value: communityNameId, projection: nil)
            try collection.update("username_id" == usernameId, to: [
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
     Service for unsubscribe a user to a community.
     - parameter username: Unique username.
     - parameter communityName: Unique communityName
     */
    public static func unsubscribe(usernameId: String, from communityNameId: String) throws {
        do {
            let c: Document? = try CommunityServices.readOne(by: "name_id", value: communityNameId, projection: nil)
            try collection.update("username_id" == usernameId, to: [
                "$pull": [
                    "subscriptions": c
                ]
            ])
        } catch let e {
            print("Subscription error: \(e)")
            throw ServicesErrors.unsubscribe
        }
    }


    /**
     TODO: TEST.
     Get subscriptions.
     - parameter username: Unique username.
     - returns: A list of community documents.
     */
    public static func getSubscriptions(from usernameId: String) throws -> Document? {
        do {
            var projection: Projection = ["subscriptions": .included]
            projection.suppressIdentifier()

            let document: Document? = try self.readOne(by: "username_id", value: usernameId, projection: projection)
            let embeddedSubs = Document(document?["subscriptions"])
            let embeddedSubsWithoutId = embeddedSubs.map({(document: Document) -> [Document?] in
                return document.map({(value: Document.Element) -> Document? in
                    var d = Document(value.value)
                    d?.removeValue(forKey: "_id")
                    return d
                }
            )}).flatMap{ $0 }

            let subsDocument: Document = ["subscriptions": embeddedSubsWithoutId]
            return subsDocument
        } catch let e {
            print("Get communities error \(e)")
            throw ServicesErrors.getCommunities
        }
    }
}
