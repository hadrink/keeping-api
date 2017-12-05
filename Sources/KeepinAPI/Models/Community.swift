//
//  Community.swift
//  KeepinAPI
//
//  Created by Rplay on 20/11/2017.
//

import Foundation
import Vapor
import KeepinServices

/// Community object.
public final class Community {

    /**
     The community name (String).
     */
    var name: String

    /**
     The community owner (User).
     */
    var admin: User?

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
            guard let communityDocument = try CommunityServices.getCommunityBy(name: self.name) else {
                throw Abort(.notFound, reason: "\(self.name) not found.")
            }

            return communityDocument.makeExtendedJSONString()
        } catch ServicesErrors.getCommunityFailed {
            let reason = "A problem is occured when we try to get the community \(self.name)."
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

