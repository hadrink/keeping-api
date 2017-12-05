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
struct UserController {

    let droplet: Droplet

    /**
     TODO: TEST.
     Register.
     - parameter request: The HTTP request.
     - returns: A JWT Token.
     */
    func register(request: Request) throws -> ResponseRepresentable {
        let user = try request.makeUser()
        _ = try user.create()

        try request.auth.authenticate(
            User.authenticate(
                Password(username: user.username, password: user.password!)
            )
        )

        return try JSON(node: [
            "access_token": try droplet.createJwtToken(user.username),
            "user": user.username
        ])
    }

    /**
     TODO: TEST.
     Login.
     - parameter request: The HTTP request.
     - returns: A JWT Token.
     */
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

    /**
     Logout.
     - parameter request: The HTTP request.
     - returns: A JSON object with a success key.
     */
    func logout(request: Request) throws -> ResponseRepresentable {
        // Clear the session
        try request.auth.unauthenticate()
        return try JSON(node: ["success": true])
    }

    /**
     Me.
     - parameter request: The HTTP request.
     - returns: A JSON object with a user.
     */
    func me(request: Request) throws -> ResponseRepresentable {
        return try request.user().get()
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
            store: store,
            show: show
        )
    }
}
