//
//  UsersController.swift
//  KeepinAPI
//
//  Created by Rplay on 28/10/2017.
//

import Vapor
import AuthProvider
import JWT

/// User Controller
final class UserController {

    let droplet: Droplet
    init(_ droplet: Droplet) {
        self.droplet = droplet
    }

    func register(request: Request) throws -> ResponseRepresentable {
        // Get our credentials
        let user = try request.makeUser()

        try request.auth.authenticate(User.authenticate(Password(username: user.username, password: user.password!)))
        _ = try user.create()

        return try JSON(node: [
            "access_token": try droplet.createJwtToken(user.username),
            "user": user
            ])
    }

    func login(request: Request) throws -> ResponseRepresentable {
        guard let username = request.data["username"]?.string, let password = request.data["password"]?.string else {
            return try Response(status: .badRequest, json: JSON(node: ["error": "Missing email or password"]))
        }
        let credentials = Password(username: username, password: password)
        let user = try User.authenticate(credentials)
        request.auth.authenticate(user)

        return try JSON(node: [
            "access_token": try droplet.createJwtToken(user.username),
            "user": user.username
            ])
    }

    func logout(request: Request) throws -> ResponseRepresentable {
        // Clear the session
        try request.auth.unauthenticate()
        return try JSON(node: ["success": true])
    }

    func me(request: Request) throws -> ResponseRepresentable {
        return try request.user().get()
    }

    func index(_ req: Request) throws -> ResponseRepresentable {
        return JSON("Yougou")
    }

    /**
     TODO: TEST.
     Get JSON response.
     - parameter req: The HTTP request (Request).
     - parameter user: The user (User).
     - returns: A ResponseReprentable object.
     */
    func show(_ req: Request, user: User) throws -> ResponseRepresentable {
        return try user.get()
    }

    /**
     TODO: TEST.
     Store a user from a JSON.
     - parameter req: The HTTP request (Request).
     - returns: A ResponseReprentable object.
     */
    func store(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.makeUser()
        return try user.create()
    }
}

/// Resource Representable extension for User Controller.
extension UserController: ResourceRepresentable {

    /**
     Make resource from a parameter /users/:user.
     */
    func makeResource() -> Resource<User> {
        return Resource(
            index: index,
            store: store,
            show: show
        )
    }
}

extension Request {

    /**
     Create user from Request.
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
}

extension Droplet {
    func  createJwtToken(_ userId: String)  throws -> String {
        let timeToLive = 5 * 60.0 // 5 minutes
        let claims:[Claim] = [
            ExpirationTimeClaim(date: Date().addingTimeInterval(timeToLive)),
            SubjectClaim(string: userId)
        ]

        let payload = JSON(claims)
        let jwt = try JWT(payload: payload, signer: self.assertSigner())

        return try jwt.createToken()
    }
}
