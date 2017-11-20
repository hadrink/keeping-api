//
//  Community.swift
//  KeepinAPI
//
//  Created by Rplay on 20/11/2017.
//

import Foundation
import Vapor

/// Community object.
final class Community {

    /**
     The community name (String).
     */
    var name: String

    /**
     The community owner (User).
     */
    var owner: User?

    /**
     Init user object.

     - parameter name: The community name (String).
     - parameter owner: The password (String?).
     */
    public init(name: String, owner: User? = nil) {
        self.name = name
        self.owner = owner
    }

    func get() -> ResponseRepresentable {
        return JSON()
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

