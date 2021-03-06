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
    static let db = try! KIDatabase.connect()
    public static var collection = db[KICollections.communities.rawValue]

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
    public static func get(by nameId: String) throws -> Document? {
        do {
            let community: Document? = try self.readOne(by: "name_id", value: nameId)
            return community
        } catch let e {
            print("Get community error \(e)")
            throw ServicesErrors.getCommunity
        }
    }

    /**
     TODO: TEST.
     Get communities asked.
     - parameter names: Communities name.
     - returns: A document with communities asked.
     */
    public static func getCommunities(by nameIds: Array<String>) throws -> CollectionSlice<Document>? {
        do {
            return try self.collection.find("name_id".in(nameIds), projecting: ["_id": .excluded])
        } catch let e {
            print("Get communities error \(e)")
            throw ServicesErrors.getCommunities
        }
    }

    /**
     Search communities by name.
     - parameter name: Communities name.
     - parameter limit: Nb max results.
     - returns: A document with communities.
     */
    public static func searchCommunitiesByNameId(from value: String, limitedTo limit: Int? = nil) throws -> CollectionSlice<Document> {
        do {
            let query = Query(aqt: AQT.contains(key: "name_id", val: value, options: .caseInsensitive))
            return try self.collection.find(query, projecting: ["_id": .excluded], limitedTo: limit)
        } catch let e {
            print("Search communities error \(e)")
            throw ServicesErrors.searchCommunities
        }
    }

}
