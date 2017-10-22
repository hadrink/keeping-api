//
//  Registration.swift
//  KeepinAPI
//
//  Created by Rplay on 22/10/2017.
//

import Foundation
import Vapor
import KeepinServices

/// Registration routes.
final class RegistationRoutes: Routes {

    func build(with drop: Droplet) {
        drop.get("login") { req in
            return "Hello user router"
        }

        /**
         POST: Register route.
         */
        drop.post("register") { req in
            guard let username = req.data["username"]?.string else {
                throw Abort(.notAcceptable, reason: "Please include a username.")
            }

            guard let password = req.data["password"]?.string else {
                throw Abort(.notAcceptable, reason: "Please include a password.")
            }

            do {
                try User(username: username, password: password).create()
            } catch UserError.usernameAlreadyExist(let userExistMessage) {
                throw Abort(.conflict, reason: userExistMessage)
            }

            return "\(username) has been created."
        }
    }
}
