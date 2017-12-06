//
//  UsersServices.swift
//  KeepinServices
//
//  Created by Rplay on 01/10/2017.
//
import MongoKitten
import Foundation

/// Users Services.
public struct UsersServices: Services {
    static let db = try! KIEnvironment.prod.database()
    static var collection = db[KICollections.users.rawValue]
}
