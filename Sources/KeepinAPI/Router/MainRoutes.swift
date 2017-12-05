//
//  MainRoutes.swift
//  KeepinAPI
//
//  Created by Rplay on 30/10/2017.
//

import Vapor
import HTTP
import AuthProvider
import JWTProvider

final class MainRoutes: RouteCollection {
    var droplet: Droplet
    init(_ droplet: Droplet) {
        self.droplet = droplet
    }
    func build(_ builder: RouteBuilder) throws {
        let api = builder.grouped("api")
        let v1 = api.grouped("v1")

        let userController = UserController(droplet: self.droplet)
        let communityController = CommunityController()

        v1.post("register", handler: userController.register)
        v1.post("login", handler: userController.login)
        v1.post("logout", handler: userController.logout)


        //NOTE: TokenAuthenticationMiddleware should be used only to fluent token auth, not JWT
        //let secured = v1.grouped(TokenAuthenticationMiddleware(User.self))
        let tokenMiddleware = PayloadAuthenticationMiddleware(try self.droplet.assertSigner(),[], User.self)
        let errorMiddleware = try ErrorMiddleware(config: droplet.config)
        let secured = v1.grouped([tokenMiddleware, errorMiddleware])
        secured.resource(Community.uniqueSlug, communityController)

        let users = secured.grouped(User.uniqueSlug)
        secured.resource(User.uniqueSlug, userController)
        users.get("me", handler: userController.me)
    }
}
