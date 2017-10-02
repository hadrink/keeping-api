//
//  Services.swift
//  KeepinAPIPackageDescription
//
//  Created by Rplay on 01/10/2017.
//
import Foundation
import MongoKitten

/// Services protocol.
protocol Services {
    /**
     Return a collection.
     */
    static var collection: MongoKitten.Collection? { get }

    /**
     Insert a document
     - parameter document: The document you want to insert.
     */
    static func create(document: Document)

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
}

/// Services protocol extension (default value).
extension Services {
    static func create(document: Document) {
        do {
            try collection?.insert(document)
        } catch let e {
            print("Failed to insert document: \(e)")
        }
    }

    static func remove(document: Document) {
        do {
            try collection?.remove("_id" == document["_id"])
        } catch let e {
            print("Failed to remove \(String(describing: document["_id"])) document: \(e)")
        }
    }

    static func update(document: Document) {
        do {
            try collection?.update("_id" == document["_id"], to: document)
        } catch let e {
            print("Failed to update \(String(describing: document["_id"])) document: \(e)")
        }
    }
}
