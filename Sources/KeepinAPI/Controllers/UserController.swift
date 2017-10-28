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
     Get JSON response (Need test).
     - parameter req: The HTTP request (Request).
     - parameter user: The user (User).
     */
    func show(_ req: Request, user: User) throws -> ResponseRepresentable {
        return try user.get()
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
            show: show
        )
    }
}
