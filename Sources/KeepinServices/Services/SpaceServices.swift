//
//  SpaceServices.swift
//  KeepinServices
//
//  Created by Rplay on 27/12/2017.
//

import Foundation
import MongoKitten

/// Space services.
public struct SpaceServices: Services {
    static let db = KIDatabase.db
    public static var collection = db[KICollections.spaces.rawValue]

    /**
     TODO: TEST.
     Get a community space.
     - parameter admin: The admintrator.
     - returns: A list of community documents.
     */
    public static func getSpace(from communityNameId: String) throws -> Document? {
        do {
            let space: Document? = try self.readOne(by: "community.name_id", value: communityNameId)
            return space
        } catch let e {
            print("Get space error \(e)")
            throw ServicesErrors.getSpace
        }
    }

    /**
     TODO: TEST.
     Create a community space.
     - parameter admin: The admintrator.
     - returns: A list of community documents.
     */
    public static func create(with community: Document) throws {
        let spaceDocument: Document = [
            "community": community,
            "messages": []
        ]

        return try self.create(document: spaceDocument)
    }

    /**
     TODO: TEST.
     Insert a message in the community space.
     - parameter message: The message content (String).
     - parameter communityName: The associate community name (String).
     - parameter username: The emetter (String).
     */
    public static func insert(message: String, in communityNameId: String, by username: String) throws {
        do {
            let messageDocument: Document = [
                "id": ObjectId(),
                "date": Date(),
                "username": username,
                "content": message
            ]
            try collection.update("community.name_id" == communityNameId, to: [
                "$addToSet": [
                    "messages": messageDocument
                ]
            ])
        } catch let e {
            print("Insert message error: \(e)")
            throw ServicesErrors.update
        }
    }
}



