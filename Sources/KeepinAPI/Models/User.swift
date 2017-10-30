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
import AuthProvider
import JWTProvider
import JWT

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

extension User: PasswordAuthenticatable {
    public static func authenticate(_ creds: Password) throws -> User {
        let userDoc = try UsersServices.getUserDocumentBy(
            username: creds.username,
            allKeys: true
        )

        guard let userFound = userDoc else {
            throw Abort(.notFound, reason: "\(creds.username) not found.")
        }

        guard let passwordFound = userFound["password"] as? String else {
            throw Abort(.internalServerError)
        }

        guard try BCrypt.Hash.verify(message: creds.password, matches: passwordFound) else {
            throw Abort(.notAcceptable, reason: "Wrong password")
        }

        return User(username: creds.username)
    }
}

extension User: TokenAuthenticatable {
    public static func authenticate(_ token: Token) throws -> User {
        let jwt = try JWT(token: token.string)
        try jwt.verifySignature(using: HS256(key: "SIGNING_KEY".makeBytes()))
        let time = ExpirationTimeClaim(date: Date())
        try jwt.verifyClaims([time])
        guard let userId = jwt.payload.object?[SubjectClaim.name]?.string else { throw AuthenticationError.invalidCredentials
        }

        return User(username: userId)
    }

    public typealias TokenType = Token
}

public class Claims: JSONInitializable {
    var subjectClaimValue : String
    var expirationTimeClaimValue : Double
    public required init(json: JSON) throws {
        guard let subjectClaimValue = try json.get(SubjectClaim.name) as String? else {
            throw AuthenticationError.invalidCredentials
        }
        self.subjectClaimValue = subjectClaimValue

        guard let expirationTimeClaimValue = try json.get(ExpirationTimeClaim.name) as String? else {
            throw AuthenticationError.invalidCredentials
        }
        self.expirationTimeClaimValue = Double(expirationTimeClaimValue)!

    }
}

extension User: PayloadAuthenticatable {
    public typealias PayloadType = Claims
    public static func authenticate(_ payload: Claims) throws -> User {
        if payload.expirationTimeClaimValue < Date().timeIntervalSince1970 {
            throw AuthenticationError.invalidCredentials
        }

        let userId = payload.subjectClaimValue

        return User(username: userId)
    }
}

extension Request {
    func user() throws -> User {
        return try auth.assertAuthenticated()
    }
}
