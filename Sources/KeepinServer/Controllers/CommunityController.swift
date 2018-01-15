//
//  CommunityController.swift
//  KeepinServer
//
//  Created by Rplay on 20/11/2017.
//

import Vapor

protocol CommunityControllerDelegate {
    /**
     Return communities sorted by activity.
     - parameter limit: Number of results.
     - returns: A responsable object.
     */
    func requestSortedCommunitiesByActivity(limit: Int) throws -> ResponseRepresentable
}

/// Community Controller
final class CommunityController {

    var delegate: CommunityControllerDelegate?

    /**
     TODO: TEST.
     Get JSON response.
     - parameter req: The HTTP request (Request).
     - returns: A ResponseReprentable object.
     */
    func index(_ req: Request) throws -> ResponseRepresentable {
        guard let delegate = self.delegate else {
            throw Abort(.internalServerError, reason: "Cannot get communities by activity")
        }

        let limit = req.data["limit"]?.int
        return try delegate.requestSortedCommunitiesByActivity(limit: limit ?? 10)
    }

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
        guard let name = req.data["name"]?.string else {
            throw Abort(.badRequest, reason: "Missing name")
        }

        let user = try req.user()
        return try Community(name: name, admin: user).create()
    }
}

/// Resource Representable extension for User Controller.
extension CommunityController: ResourceRepresentable {

    /**
     Make resource from a parameter /communities/:community.
     */
    func makeResource() -> Resource<Community> {
        return Resource(
            index: index,
            store: store,
            show: show
        )
    }
}

