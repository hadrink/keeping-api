//
//  MainRoutes.swift
//  KeepinServer
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
        let spaceController = SpaceController()
        let chatController = ChatController(communityController: communityController)

        // Builders
        let api = builder.grouped("api")
        let errorHandler = api.grouped(errorMiddleware)
        let v1 = errorHandler.grouped("v1")
        let secured = v1.grouped(tokenMiddleware)
        let communities = v1.grouped(Community.uniqueSlug)

        // Public resources
        v1.post("register", handler: userController.register)
        v1.post("login", handler: userController.login)
        v1.post("logout", handler: userController.logout)
        communities.get("search", handler: communityController.search)
        v1.resource(Community.uniqueSlug, communityController)
        v1.resource(Space.uniqueSlug, spaceController)

        //NOTE: TokenAuthenticationMiddleware should be used only to fluent token auth, not JWT
        //let secured = v1.grouped(TokenAuthenticationMiddleware(User.self))

        // Private resources
        secured.post(Community.uniqueSlug, handler: communityController.store)
        secured.resource(User.uniqueSlug, userController)
        secured.resource("subscriptions", subscriptionController)

        secured.patch(Space.uniqueSlug, ":spaces") { req in
            let space = try req.parameters.next(Space.self)
            return try spaceController.update(req, space: space)
        }
        
        let users = secured.grouped(User.uniqueSlug)
        users.get("me", handler: userController.me)
        users.get("communities", handler: userController.communities)

        v1.socket("chat", handler: chatController.handler)
    }
}
