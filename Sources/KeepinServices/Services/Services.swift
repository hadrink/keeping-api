//
//  Services.swift
//  KeepinServices
//
//  Created by Rplay on 01/10/2017.
//
import Foundation
import MongoKitten

/// Services errors.
public enum ServicesErrors: Error {
    case read
    case subscribe
    case unsubscribe
    case getCommunities
    case getCommunity
    case getSpace
    case create
    case update
}

/// Services protocol.
public protocol Services {
    /**
     Return a collection.
     */
    static var collection: MongoKitten.Collection { get }

    /**
     Insert a document
     - parameter document: The document you want to insert.
     */
    static func create(document: Document) throws

    /**
     Remove a document from the document object id.
     - parameter document: The document you want to remove.
     */
    static func remove(document: Document)

    /**
     Update a document. Replace all existing keys.
     - parameter document: The document you want to update.
     */
    static func update(document: Document)

    /**
     Read a document by key == value.
     - parameter key: The document key you are looking for.
     - parameter value: The value you want to compare.
     - parameter projection: Define keys you want return.
     */
    static func readOne(by key: String, value: String, projection: Projection?) throws -> Document?

    /**
     Read multiple documents by key == value.
     - parameter key: The document key you are looking for.
     - parameter value: The value you want to compare.
     - parameter projection: Define keys you want return.
     */
    static func read(by key: String, value: String, projection: Projection?) throws -> CollectionSlice<Document>?
}

/// Services protocol extension (default value).
extension Services {
    public static func create(document: Document) throws {
        do {
            try collection.insert(document)
        } catch let e {
            print("Failed to insert document: \(e)")
            throw ServicesErrors.create
        }
    }

    public static func remove(document: Document) {
        do {
            try collection.remove("_id" == document["_id"])
        } catch let e {
            print("Failed to remove \(String(describing: document["_id"])) document: \(e)")
        }
    }

    public static func update(document: Document) {
        do {
            try collection.update("_id" == document["_id"], to: document)
        } catch let e {
            print("Failed to update \(String(describing: document["_id"])) document: \(e)")
        }
    }

    public static func readOne(by key: String, value: String, projection: Projection? = ["_id": .excluded]) throws -> Document? {
        do {
            guard let projecting = projection else {
                return try collection.findOne(key == value)
            }

            return try collection.findOne(key == value, projecting: projecting)
        } catch let e {
            print("Get \(key) by \(value) error: \(e)")
            throw ServicesErrors.read
        }
    }

    public static func read(by key: String, value: String, projection: Projection? = ["_id": .excluded]) throws -> CollectionSlice<Document>? {
        do {
            guard let projecting = projection else {
                return try collection.find(key == value)
            }

            return try collection.find(key == value, projecting: projecting)
        } catch let e {
            print("Get \(key) by \(value) error: \(e)")
            throw ServicesErrors.read
        }
    }
}
