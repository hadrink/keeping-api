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
        // Middlewares
        let errorMiddleware = try ErrorMiddleware(config: droplet.config)
        let tokenMiddleware = PayloadAuthenticationMiddleware(try self.droplet.assertSigner(),[], User.self)

        // Controllers
        let userController = UserController(droplet: self.droplet)
        let communityController = CommunityController()
        let subscriptionController = SubscriptionController()

        // Builders
        let api = builder.grouped("api")
        let errorHandler = api.grouped(errorMiddleware)
        let v1 = errorHandler.grouped("v1")
        let secured = v1.grouped(tokenMiddleware)

        // Public resources
        v1.post("register", handler: userController.register)
        v1.post("login", handler: userController.login)
        v1.post("logout", handler: userController.logout)
        v1.resource(Community.uniqueSlug, communityController)

        //NOTE: TokenAuthenticationMiddleware should be used only to fluent token auth, not JWT
        //let secured = v1.grouped(TokenAuthenticationMiddleware(User.self))

        // Private resources
        secured.post(Community.uniqueSlug, handler: communityController.store)
        secured.resource(User.uniqueSlug, userController)
        secured.resource("subscriptions", subscriptionController)
        let users = secured.grouped(User.uniqueSlug)
        users.get("me", handler: userController.me)
    }
}
