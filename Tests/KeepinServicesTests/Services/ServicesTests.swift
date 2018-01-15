//
//  ServicesTests.swift
//  KeepinServicesTests
//
//  Created by Rplay on 01/10/2017.
//

import Foundation
import XCTest
@testable import MongoKitten
@testable import KeepinServices

class ServicesTests: XCTestCase {
    var db: Database?
    var collection: MongoKitten.Collection?

    override func setUp() {
        super.setUp()

        self.db = try? KIEnvironment.prod.database()
        self.collection = db?[KICollections.users.rawValue]
    }

    /**
     Test create.
     */
//    func testCreate() {
//        let userDocument: Document = ["username":  "jean"]
//        UsersServices.create(document: userDocument)
//
//        do {
//            guard let documents = try collection?.find("username" == "jean") else {
//                XCTFail()
//                return
//            }
//
//            for document in documents {
//                XCTAssertNotNil(document)
//            }
//        } catch let e {
//            print(e)
//            XCTFail()
//        }
//    }

    /**
     Test update.
     */
    func testUpdate() {

        // Create a new document.
        let userDocument: Document = ["username":  "michel"]

        do {

            // Insert or update it if exists.
            guard var newDocumentInserted = try collection?.findAndUpdate(with: userDocument, upserting: true) else {
                XCTFail()
                return
            }

            // Update username key to "robert"
            newDocumentInserted["username"] = "robert"

            // Launch update service from Services.
            UsersServices.update(document: newDocumentInserted)
            guard let documentsFound = try collection?.find("username" == "robert") else {
                XCTFail()
                return
            }

            for document in documentsFound {
                // Check if a document with the username "robert" is found.
                XCTAssert(document["username"] === "robert")
            }

        } catch let e {
            print(e)
            XCTFail()
        }
    }

    /**
     Test remove.
     */
    func testDelete() {
        // Document to insert.
        let userDocument: Document = ["username":  "jean"]

        do {
            // Insert and retrieve the document.
            guard let newDocumentInserted = try collection?.findAndUpdate(with: userDocument, upserting: true) else {
                XCTFail()
                return
            }

            // Check if it exists.
            XCTAssertNotNil(newDocumentInserted)
            UsersServices.remove(document: newDocumentInserted)

            // Check if it is removed.
            XCTAssertNil(try collection?.findOne("_id" == newDocumentInserted["_id"]))
        } catch let e {
            print(e)
            XCTFail()
        }
    }
}
