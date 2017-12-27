//
//  CommunityServices.swift
//  KeepinServices
//
//  Created by Rplay on 20/11/2017.
//

import Foundation
import MongoKitten

/// Community services.
public struct CommunityServices: Services {
    static let db = try! KIEnvironment.prod.database()
    static var collection = db[KICollections.communities.rawValue]

    /**
     TODO: TEST.
     Get administrator communities.
     - parameter admin: The admintrator.
     - returns: A list of community documents.
     */
    public static func getCommunities(from admin: String) throws -> Document? {
        do {
            let communities: CollectionSlice<Document>? = try self.read(by: "admin", value: admin)
            return communities?.makeDocument()
        } catch let e {
            print("Get communities error \(e)")
            throw ServicesErrors.getCommunities
        }
    }

    /**
     TODO: TEST.
     Get a community document.
     - parameter name: Community name.
     - returns: A community document.
     */
    public static func get(by name: String) throws -> Document? {
        do {
            let community: Document? = try self.read(by: "name", value: name)
            return community
        } catch let e {
            print("Get community error \(e)")
            throw ServicesErrors.getCommunity
        }
    }
}
