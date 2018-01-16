//
//  SubscriptionController.swift
//  KeepinServer
//
//  Created by Rplay on 07/12/2017.
//

import Vapor

/// Community Controller
struct SubscriptionController {

    /**
     TODO: TEST.
     Get JSON response.
     - parameter req: The HTTP request (Request).
     - returns: A ResponseReprentable object.
     */
    func index(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.user()
        return try user.getSubscriptions()
    }

    /**
     TODO: TEST.
     Store a user from a JSON.
     - parameter req: The HTTP request (Request).
     - returns: A ResponseReprentable object.
     */
    func store(_ req: Request) throws -> ResponseRepresentable {
        guard let name = req.data["communityName"]?.string else {
            throw Abort(.badRequest, reason: "Missing community name")
        }

        return try req.user().subscribe(to: Community(name: name))
    }

    /**
     TODO: TEST.
     Unsubscribe a user from a community.
     - parameter req: The HTTP request (Request).
     - returns: A ResponseReprentable object.
     */
    func destroy(_ req: Request, community: Community) throws -> ResponseRepresentable {
        return try req.user().unsubscribe(from: community)
    }
}

/// Resource Representable extension for Subscription Controller.
extension SubscriptionController: ResourceRepresentable {

    /**
     Make resource from a parameter /subscriptions/:community.
     */
    func makeResource() -> Resource<Community> {
        return Resource(
            index: index,
            store: store,
            destroy: destroy
        )
    }
}
