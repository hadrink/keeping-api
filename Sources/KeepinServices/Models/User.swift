//
//  User.swift
//  KeepinServices
//
//  Created by Rplay on 21/10/2017.
//
import Foundation
import MongoKitten
import BCrypt

/// User error
public enum UserError: Error {
    case usernameAlreadyExist(message: String)
}

/// User object
public final class User {

    /**
     Username (String).
     */
    var username: String

    /**
     Password (String).
     */
    var password: String

    /**
     Init user object.

     - parameter username: The username (String).
     - parameter password: The password (String).
     */
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    /**
     Insert user in database.
     */
    public func create() throws {
        let existingUser = UsersServices.getUserDocumentBy(username: self.username)
        guard existingUser == nil else {
            let message = "Username \(self.username) already exist"
            throw UserError.usernameAlreadyExist(message: message)
        }

        let passwordHash = try BCrypt.Hash.make(message: self.password)
        let userDocument: Document = [
            "username": self.username,
            "password": passwordHash.makeString()
        ]

        UsersServices.create(document: userDocument)
    }
}
