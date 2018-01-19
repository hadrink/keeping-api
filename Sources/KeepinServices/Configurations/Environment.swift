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
    static var db: Database = try! connect()

    static func connect() throws -> Database {
        let config = try! Config()
        guard let databaseUser = config["mongodb", "database_user"]?.string ?? config["server", "database_user"]?.string else {
            throw Abort(.internalServerError, reason: "DATABASE_USER is missing")
        }

        guard let databasePwd = config["mongodb", "database_password"]?.string ?? config["server", "database_password"]?.string else {
            throw Abort(.internalServerError, reason: "DATABASE_PASSWORD is missing")
        }

        guard let databaseURI = config["mongodb", "database_uri"]?.string ?? config["server", "database_uri"]?.string else {
            throw Abort(.internalServerError, reason: "DATABASE_URI is missing")
        }

        let databaseUrl = "mongodb://\(databaseUser):\(databasePwd)@\(databaseURI)"
        return try! Database(databaseUrl)
    }
}


