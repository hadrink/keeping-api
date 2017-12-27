//
//  Space.swift
//  KeepinAPI
//
//  Created by Rplay on 27/12/2017.
//

import Foundation
import Vapor
import KeepinServices
import MongoKitten

/// Space object.
public final class Space {

    /**
     The community (String).
     */
    var community: Community

    /**
     Init space object.

     - parameter community: A space depends of a community (Community)
     */
    public init(community: Community) {
        self.community = community
    }


    /**
     TODO: TEST.
     Get community space.

     - returns: A JSON String response.
     */
    public func get() throws -> ResponseRepresentable {
        guard let spaceDocument: Document = try SpaceServices.getSpace(from: community.name) else {
            throw Abort(.notFound, reason: "\(community.name) space not found.")
        }

        return spaceDocument.makeExtendedJSONString()
    }

    /**
     TODO: TEST.
     Get community space.

     - returns: A JSON String response.
     */
    public func create() throws -> ResponseRepresentable {
        guard let communityDocument: Document = try CommunityServices.get(by: community.name) else {
            throw Abort(.notFound, reason: "\(community.name) not found.")
        }

        do {
            try SpaceServices.create(with: communityDocument)
        } catch ServicesErrors.create {
            throw Abort(.notFound, reason: "A problem is occured when we try to create \(community.name) space")
        }

        return try self.get()
    }

    /**
     TODO: TEST.
     Insert a message in the community space.

     - returns: A JSON String response.
     */
    public func insert(message: String) throws -> ResponseRepresentable {
        do {
            try SpaceServices.insert(message: message, in: community.name)
        } catch ServicesErrors.update {
            let r = "A problem is occured when we try to insert '\(message)'in \(community.name) space"
            throw Abort(.internalServerError, reason: r)
        }

        return try self.get()
    }
}

/// Space extension type of Parameterizable.
extension Space: Parameterizable {

    public static var uniqueSlug: String {
        return "spaces"
    }

    public static func make(for parameter: String) throws -> Space {
        let community = Community(name: parameter)
        return Space(community: community)
    }
}


