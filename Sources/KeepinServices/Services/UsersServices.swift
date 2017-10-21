//
//  UsersServices.swift
//  KeepinServices
//
//  Created by Rplay on 01/10/2017.
//
import MongoKitten
import Foundation

/// Users Services.
struct UsersServices: Services {
    static let db = try? KIEnvironment.prod.database()
    static var collection = db?[KICollections.users.rawValue]

    /**
     Get user document by username.
     - parameter principal: The username (String).
     - returns: The user document (Document?).
     */
    static func getUserDocumentBy(username: String) -> Document? {
        do {
            return try collection?.findOne("username" == username)
        } catch let e {
            print("Get user by username error: \(e)")
            return nil
        }
    }
}
