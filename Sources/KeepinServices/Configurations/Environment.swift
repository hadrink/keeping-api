//
//  Environment.swift
//  KeepinServices
//
//  Created by Rplay on 01/10/2017.
//
import MongoKitten
import Foundation
import Vapor

struct KIDatabase {
    static let connect: Database = {
        let config = try! Config()
        return try! Database(config["mongodb", "uri"]?.string ?? config["server", "mongo_uri"]!.string!)
    }()
}


