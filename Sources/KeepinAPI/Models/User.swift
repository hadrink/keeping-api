//
//  User.swift
//  KeepinServices
//
//  Created by Rplay on 21/10/2017.
//
import Foundation
import KeepinServices
import Vapor
import MongoKitten
import BCrypt

/// User error
public enum UserError: Error {
    case usernameAlreadyExist(message: String)
    case passwordIsMissing(message: String)
}

/// User object
public final class User {

    /**
     Username (String).
     */
    var username: String

    /**
     Password (String?).
     */
    var password: String?

    /**
     Init user object.

     - parameter username: The username (String).
     - parameter password: The password (String?).
     */
    public init(username: String, password: String? = nil) {
        self.username = username
        self.password = password
    }

    /**
     Insert user in database.
     */
    public func create() throws -> ResponseRepresentable {
        let existingUser = try UsersServices.getUserDocumentBy(username: self.username)
        guard existingUser == nil else {
            let reason = "Username \(self.username) already exist"
            throw Abort(.unauthorized, reason: reason)
        }

        let passwordHash = try BCrypt.Hash.make(message: self.password!)
        let userDocument: Document = [
            "username": self.username,
            "password": passwordHash.makeString()
        ]

        UsersServices.create(document: userDocument)
        return try self.get()
    }

    /**
     Get user from database.
     */
    public func get() throws -> ResponseRepresentable {
        do {
            guard let userDocument = try UsersServices.getUserDocumentBy(username: self.username) else {
                throw Abort(.notFound, reason: "\(self.username) not found.")
            }

            return userDocument.makeExtendedJSONString()
        } catch ServicesErrors.getUserFailed {
            let reason = "A problem is occured when we try to get the user \(self.username)."
            throw Abort(.internalServerError, reason: reason)
        }
    }
}

extension User: Parameterizable {
    public static var uniqueSlug: String {
        return "users"
    }

    public static func make(for parameter: String) throws -> User {
        return User(username: parameter)
    }
}
