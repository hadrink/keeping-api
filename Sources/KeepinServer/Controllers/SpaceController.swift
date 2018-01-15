//
//  SpaceController.swift
//  KeepinServer
//
//  Created by Rplay on 27/12/2017.
//

import Vapor

/// Space Controller
final class SpaceController {

    /**
     TODO: TEST.
     Get JSON response.
     - parameter req: The HTTP request (Request).
     - parameter space: The community space (Space).
     - returns: A ResponseReprentable object.
     */
    func show(request: Request, space: Space) throws -> ResponseRepresentable {
        return try space.get()
    }

    /**
     TODO: TEST.
     Store a space from a JSON.
     - parameter req: The HTTP request (Request).
     - returns: A ResponseReprentable object.
     */
    func store(_ req: Request) throws -> ResponseRepresentable {
        guard let communityName = req.data["community"]?.string else {
            throw Abort(.badRequest, reason: "Missing community name")
        }

        let space = Space(community: Community(name: communityName))
        return try space.create()
    }

    /**
     TODO: TEST.
     Update a community space from a JSON.
     - parameter req: The HTTP request (Request).
     - returns: A ResponseReprentable object.
     */
    func update(_ req: Request, space: Space) throws -> ResponseRepresentable {
        let user = try req.user()

        guard try user.isAdmin(community: space.community) else {
            throw Abort(.unauthorized, reason: "You are not authorized to update this space")
        }

        guard let m = req.data["message"]?.string else {
            throw Abort(.badRequest, reason: "Message is missing")
        }

        return try space.insert(message: m, by: user)
    }
}

/// Resource Representable extension for Space Controller.
extension SpaceController: ResourceRepresentable {

    /**
     Make resource from a parameter /spaces/:community.
     */
    func makeResource() -> Resource<Space> {
        return Resource(
            store: store,
            show: show
        )
    }
}


