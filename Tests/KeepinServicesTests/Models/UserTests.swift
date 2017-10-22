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
@testable import BCrypt

class UserTests: XCTestCase {
    var db: Database?
    var collection: MongoKitten.Collection?

    override func setUp() {
        super.setUp()

        self.db = try? KIEnvironment.prod.database()
        self.collection = db?[KICollections.users.rawValue]
    }

    /**
     Test create user.
     */
    func testCreateUser() {
        let user = User(username: "Paul", password: "password")
        try? user.create()
        let userFound = UsersServices.getUserDocumentBy(username: "Paul")

        guard let password = userFound?["password"] as? String,
              let passwordIsCorrect = try? BCrypt.Hash.verify(message: "password", matches: password)
        else {
            XCTFail()
            return
        }

        XCTAssert(userFound?["username"] === "Paul")
        XCTAssert(passwordIsCorrect)
    }

    /**
     Test user already exist.
     */
    func testUserAlreadyExist() {
        let username = "UserAlreadyExist?"
        _ = try? collection?.remove("username" == username)

        let user1 = User(username: username, password: "password")
        try? user1.create()

        let user2 = User(username: username, password: "password")

        do {
            try user2.create()
        } catch UserError.usernameAlreadyExist(message: let errorMessage) {
            XCTAssertEqual(errorMessage, "Username \(user2.username) already exist")
        } catch let e {
            print(e)
            XCTFail()
        }
    }
}

