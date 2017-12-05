//
//  CommunityController.swift
//  KeepinAPI
//
//  Created by Rplay on 20/11/2017.
//

import Vapor

/// Community Controller
struct CommunityController {

    /**
     TODO: TEST.
     Get JSON response.
     - parameter req: The HTTP request (Request).
     - parameter user: The community (Community).
     - returns: A ResponseReprentable object.
     */
    func show(_ req: Request, community: Community) throws -> ResponseRepresentable {
        return try community.get()
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
extension CommunityController: ResourceRepresentable {

    /**
     Make resource from a parameter /communities/:community.
     */
    func makeResource() -> Resource<Community> {
        return Resource(
            store: store,
            show: show
        )
    }
}

