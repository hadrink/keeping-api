//
//  UserTests.swift
//  KeepinAPIServicesTests
//
//  Created by Rplay on é&/10/2017.
//

import Foundation
import XCTest
@testable import MongoKitten
@testable import KeepinServices

class UserTests: XCTestCase {
    var db: Database?
    var collection: MongoKitten.Collection?

    override func setUp() {
        super.setUp()

        self.db = try? KIEnvironment.prod.database()
        self.collection = db?[KICollections.users.rawValue]
    }

    /**
     Test create user document by principal.
     */
    func testCreateUser() {
        let user = User(username: "Paul", password: "password")
        try? user.create()
        let userFound = UsersServices.getUserDocumentBy(username: "Paul")

        print(userFound)
        XCTAssert(userFound?["username"] === "Paul")
    }
}

