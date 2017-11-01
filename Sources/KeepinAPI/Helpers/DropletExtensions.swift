//
//  DropletExtensions.swift
//  KeepinAPI
//
//  Created by Rplay on 31/10/2017.
//

import Vapor
import JWT

/// Droplet extension.
extension Droplet {

    /**
     Setup.
     */
    public func setup() throws {
        try collection(MainRoutes(self))
        let userController = UserController(drop)
        resource(User.uniqueSlug, userController)
    }

    /**
     Create a JWT token.
     - parameter: The unique username (String).
     - returns: A token JWT (String).
     */
    public func createJwtToken(_ username: String)  throws -> String {
        let timeToLive = 5 * 60.0 // 5 minutes
        let claims:[Claim] = [
            ExpirationTimeClaim(date: Date().addingTimeInterval(timeToLive)),
            SubjectClaim(string: username)
        ]

        let payload = JSON(claims)
        let jwt = try JWT(payload: payload, signer: self.assertSigner())

        return try jwt.createToken()
    }
}

