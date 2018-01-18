//
//  User.swift
//  KeepinServices
//
//  Created by Rplay on 21/10/2017.
//
import KeepinServices
import Vapor
import MongoKitten
import BCrypt
import AuthProvider
import JWTProvider
import JWT
import Validation

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
     Email (String).
     */
    var email: String?

    /**
     Password (String?).
     */
    var password: String?

    /**
     Init user object.

     - parameter username: The username (String).
     - parameter password: The password (String?).
     */
    public init(username: String, email: String? = nil, password: String? = nil) throws {
        self.username = username.lowercased()
        self.email = email
        self.password = password

        guard let email = email else {
            return
        }

        try NameValidator().validate(username)
        try EmailValidator().validate(email)
    }

    /**
     Insert user in database.
     */
    public func create() throws -> ResponseRepresentable {
        let existingUser = try UsersServices.readOne(by: "username", value: self.username)
        guard existingUser == nil else {
            let reason = "Username \(self.username) already exist"
            throw Abort(.unauthorized, reason: reason)
        }

        let passwordHash = try BCrypt.Hash.make(message: self.password!)
        let userDocument: Document = [
            "username": self.username,
            "password": passwordHash.makeString()
        ]

        try UsersServices.create(document: userDocument)
        return try self.get()
    }

    /**
     Get user from database.
     */
    public func get() throws -> ResponseRepresentable {
        do {
            guard let userDocument = try UsersServices.readOne(
                by: "username",
                value: self.username,
                projection: ["_id": .excluded, "password": .excluded, "subscriptions": .excluded]
            ) else {
                throw Abort(.notFound, reason: "\(self.username) not found.")
            }

            return userDocument.makeExtendedJSONString()
        } catch ServicesErrors.read {
            let reason = "A problem is occured when we try to get the user \(self.username)."
            throw Abort(.internalServerError, reason: reason)
        }
    }

    /**
     Get community subscriptions.
     */
    public func getSubscriptions() throws -> ResponseRepresentable {
        do {
            guard let commmunitiesCollection = try UsersServices.getSubscriptions(from: self.username) else {
                throw Abort(.notFound, reason: "\(self.username) not found.")
            }

            return commmunitiesCollection.makeExtendedJSONString()
        } catch ServicesErrors.getCommunities {
            let reason = "A problem is occured we try to get \(self.username) communities"
            throw Abort(.internalServerError, reason: reason)
        }
    }

    /**
     TODO: TEST.
     Unsubscribe a user to a community.
     - parameter community: Community you want unsub.

     - returns: A JSON String response.
     */
    public func unsubscribe(from community: Community) throws -> ResponseRepresentable {
        do {
            try UsersServices.unsubscribe(username: self.username, from: community.name)
        } catch ServicesErrors.unsubscribe {
            let reason = "A problem is occured when we try to unsusbscribe \(self.username) to \(community.name)"
            throw Abort(.internalServerError, reason: reason)
        }

        return try self.getSubscriptions()
    }

    /**
     TODO: TEST.
     Subscribe a user to a community.

     - returns: A JSON String response.
     */
    public func subscribe(to community: Community) throws -> ResponseRepresentable {
        do {
            try UsersServices.subscribe(username: self.username, to: community.name)
        } catch ServicesErrors.subscribe {
            let reason = "A problem is occured when we try to susbscribe \(self.username) to \(community.name)"
            throw Abort(.internalServerError, reason: reason)
        }

        return try self.getSubscriptions()
    }

    /**
     TODO: TEST.
     Get community subscriptions.
     */
    public func getMyCommunities() throws -> ResponseRepresentable {
        do {
            guard let mine = try CommunityServices.getCommunities(from: self.username) else {
                throw Abort(.notFound, reason: "\(self.username) not found.")
            }

            return mine.makeExtendedJSONString()
        } catch ServicesErrors.getCommunities {
            let reason = "A problem is occured we try to get \(self.username) communities"
            throw Abort(.internalServerError, reason: reason)
        }
    }

    /**
     TODO: TEST.
     Check is this user is admin of the community given.
     - parameter community: The community given (Community)

     - returns: Is admin or not.
     */
    public func isAdmin(community: Community) throws -> Bool {
        do {
            let c = try CommunityServices.get(by: community.name)
            return String(c?["admin"]) == self.username
        } catch ServicesErrors.getCommunity {
            let reason = "A problem is occured we try to get \(self.username) communities"
            throw Abort(.internalServerError, reason: reason)
        }
    }
}

/// User extension type of Parameterizable.
extension User: Parameterizable {

    public static var uniqueSlug: String {
        return "users"
    }

    public static func make(for parameter: String) throws -> User {
        do {
            return try User(username: parameter)
        } catch let e {
            throw Abort(.badRequest, reason: e.localizedDescription)
        }
    }
}

/// User extension type of PasswordAuthenticatable.
extension User: PasswordAuthenticatable {

    public static func authenticate(_ creds: Password) throws -> User {
        let userDoc = try UsersServices.readOne(by: "username", value: creds.username, projection: nil)

        guard let userFound = userDoc else {
            throw Abort(.notFound, reason: "\(creds.username) not found.")
        }

        guard let passwordFound = userFound["password"] as? String else {
            throw Abort(.internalServerError)
        }

        guard try BCrypt.Hash.verify(message: creds.password, matches: passwordFound) else {
            throw Abort(.notAcceptable, reason: "Wrong password")
        }

        do {
            return try User(username: creds.username)
        } catch ValidatorError.failure( _, let reason) {
            throw Abort(.badRequest, reason: reason)
        }
    }
}

/// User extension type of TokenAuthenticatable.
extension User: TokenAuthenticatable {

    public typealias TokenType = Token

    public static func authenticate(_ token: Token) throws -> User {
        let jwt = try JWT(token: token.string)

        guard let keyString = drop?.config["jwt", "signer", "key"]?.string else {
            PrintLogger().fatal("Jwt key is missing")
            throw Abort(.internalServerError)
        }

        try jwt.verifySignature(using: RS256(key: keyString.bytes.base64Decoded))
        let time = ExpirationTimeClaim(date: Date())
        try jwt.verifyClaims([time])
        guard let userId = jwt.payload.object?[SubjectClaim.name]?.string else {
            throw AuthenticationError.invalidCredentials
        }

        do {
            return try User(username: userId)
        } catch ValidatorError.failure( _, let reason) {
            throw Abort(.badRequest, reason: reason)
        }
    }
}

/// User extension type of PayloadAuthenticatable.
extension User: PayloadAuthenticatable {

    public typealias PayloadType = Claims

    public static func authenticate(_ payload: Claims) throws -> User {
        if payload.expirationTimeClaimValue < Date().timeIntervalSince1970 {
            throw AuthenticationError.invalidCredentials
        }

        let userId = payload.subjectClaimValue

        do {
            return try User(username: userId)
        } catch ValidatorError.failure( _, let reason) {
            throw Abort(.badRequest, reason: reason)
        }
    }
}
