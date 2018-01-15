//
//  RequestExtensions.swift
//  KeepinServer
//
//  Created by Rplay on 31/10/2017.
//

import Vapor
import Validation

/// Request extension.
extension Request {

    /**
     Create user from Request.
     - returns: A user.
     */
    public func makeUser() throws -> User {
        guard let json = self.json else { throw Abort.badRequest }

        guard let username = json["username"]?.string else {
            throw Abort(.badRequest, reason: "Missing username.")
        }

        guard let email = json["email"]?.string else {
            throw Abort(.badRequest, reason: "Missing email.")
        }

        guard let password = json["password"]?.string else {
            throw Abort(.badRequest, reason: "Missing password.")
        }

        do {
            return try User(username: username, email: email, password: password)
        } catch ValidatorError.failure( _, let reason) {
            throw Abort(.badRequest, reason: reason)
        }
    }

    /**
     Get user from the JWT Token.
     - returns: A user.
     */
    public func user() throws -> User {
        return try auth.assertAuthenticated()
    }
}

