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
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    public init(username: String) {
        self.username = username
    }

    /**
     Insert user in database.
     */
    public func create() throws {
        let existingUser = try? UsersServices.getUserDocumentBy(username: self.username)
        guard existingUser == nil else {
            let message = "Username \(self.username) already exist"
            throw UserError.usernameAlreadyExist(message: message)
        }

        guard let password = self.password else {
            throw UserError.passwordIsMissing(message: "Password is missing.")
        }

        let passwordHash = try BCrypt.Hash.make(message: password)
        let userDocument: Document = [
            "username": self.username,
            "password": passwordHash.makeString()
        ]

        UsersServices.create(document: userDocument)
    }

    /**
     Get user from database.
     */
    public func get() throws -> ResponseRepresentable {
        do {
            guard let userDocument = try UsersServices.getUserDocumentBy(username: self.username) else {
                let message = ["error" : "\(self.username) not found."]
                return try JSON(node: message)
            }

            return userDocument.makeExtendedJSONString()
        } catch ServicesErrors.getUserFailed {
            let message = ["error" : "A problem is occured when we try to get the user \(self.username)."]
            return try JSON(node: message)
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
