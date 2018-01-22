//
//  Community.swift
//  KeepinServer
//
//  Created by Rplay on 20/11/2017.
//

import Foundation
import Vapor
import KeepinServices
import MongoKitten

/// Community object.
public final class Community {

    /**
     The community name (String).
     */
    var name: String

    /**
     The community admin (User).
     */
    var admin: User?

    /**
     The community identifier (String).
     */
    var nameId: String {
        return self.name.lowercased()
    }

    /**
     Init community object.

     - parameter name: The community name (String).
     - parameter owner: The password (String?).
     */
    public init(name: String, admin: User? = nil) {
        self.name = name
        self.admin = admin
    }

    /**
     TODO: TEST.
     Get Community.

     - returns: A JSON String response.
     */
    public func get() throws -> ResponseRepresentable {
        do {
            guard let communityDocument = try CommunityServices.readOne(by: "name_id", value: self.nameId) else {
                throw Abort(.notFound, reason: "\(self.name) not found.")
            }

            return communityDocument.makeExtendedJSONString()
        } catch ServicesErrors.read {
            let reason = "A problem is occured when we try to get the community \(self.name)."
            throw Abort(.internalServerError, reason: reason)
        }
    }

    /**
     TODO: TEST.
     Create Community.

     - returns: A JSON String response.
     */
    public func create() throws -> ResponseRepresentable {
        guard let admin = self.admin else {
            throw Abort(.unauthorized, reason: "Missing admin user")
        }

        let existingCommunity = try CommunityServices.readOne(by: "name_id", value: self.nameId)
        guard existingCommunity == nil else {
            let reason = "Community \(self.name) already exist"
            throw Abort(.unauthorized, reason: reason)
        }

        let communityDocument: Document = [
            "name_id": self.nameId,
            "name": self.name,
            "admin": admin.username
        ]

        try CommunityServices.create(document: communityDocument)
        try SpaceServices.create(with: communityDocument)
        return try self.get()
    }

    /**
     Get communities
     - parameter communities: Communities searched.

     - returns: A JSON String response.
     */
    static func get(communities: Array<Community>) throws -> ResponseRepresentable {
        let nameIds = communities.map({(community: Community) -> String in
            return community.nameId
        })

        do {
            guard let communities = try CommunityServices.getCommunities(by: nameIds) else {
                throw Abort(.notFound, reason: "Communities not found.")
            }

            return communities.makeDocument().makeExtendedJSONString()
        } catch ServicesErrors.getCommunities {
            let reason = "A problem is occured when we try to get communities."
            throw Abort(.internalServerError, reason: reason)
        }
    }

    /**
     Search communities by name from value.
     - parameter value: A string value.
     - parameter limit: Nb max results.
     - returns: A JSON String response.
     */
    static func searchCommunitiesByName(from value: String, limitedTo limit: Int? = nil) throws -> ResponseRepresentable {
        do {
            let user = try User(username: value)
            let communities = try CommunityServices.searchCommunitiesByNameId(from: user.usernameId, limitedTo: limit)
            guard try communities.count() > 0 else {
                throw Abort(.notFound, reason: "No result found")
            }

            return communities.makeDocument().makeExtendedJSONString()
        } catch ServicesErrors.searchCommunities {
            let reason = "A problem is occured when we try to search communities."
            throw Abort(.internalServerError, reason: reason)
        }
    }
}

/// Commnunity extension type of Parameterizable.
extension Community: Parameterizable {

    public static var uniqueSlug: String {
        return "communities"
    }

    public static func make(for parameter: String) throws -> Community {
        return Community(name: parameter)
    }
}

