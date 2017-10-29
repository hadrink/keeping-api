//
//  UsersController.swift
//  KeepinAPI
//
//  Created by Rplay on 28/10/2017.
//

import Vapor

/// User Controller
final class UserController {

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
