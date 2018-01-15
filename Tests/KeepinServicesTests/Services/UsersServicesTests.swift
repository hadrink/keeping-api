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

class UsersServicesTests: XCTestCase {
    var db: Database?
    var collection: MongoKitten.Collection?

    override func setUp() {
        super.setUp()

        self.db = try? KIEnvironment.prod.database()
        self.collection = db?[KICollections.users.rawValue]
    }

    /**
     Test get user document by principal.
     */
//    func testGetUserDocumentByUsername() {
//        let userDocument: Document = ["username" : "jean"]
//        UsersServices.create(document: userDocument)
//        let userDocumentFound = UsersServices.getUserDocumentBy(username: "jean")
//        XCTAssert(userDocumentFound?["username"] === "jean")
//    }
}
