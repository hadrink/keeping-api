//
//  RequestExtensions.swift
//  KeepinAPI
//
//  Created by Rplay on 31/10/2017.
//

import Vapor

/// Request extension.
extension Request {

    /**
     Create user from Request.
     - returns: A user.
     */
    func makeUser() throws -> User {
        guard let json = self.json else { throw Abort.badRequest }

        guard let username = json["username"]?.string else {
            throw Abort(.badRequest, reason: "Missing username.")
        }

        guard let password = json["password"]?.string else {
            throw Abort(.badRequest, reason: "Missing password.")
        }

        return User(username: username, password: password)
    }

    /**
     Get user from the JWT Token.
     - returns: A user.
     */
    func user() throws -> User {
        return try auth.assertAuthenticated()
    }
}

