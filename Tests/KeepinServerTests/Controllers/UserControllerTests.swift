//
//  UserControllerTests.swift
//  KeepinServerTests
//
//  Created by Rplay on 03/02/2018.
//

import Foundation
import XCTest
import Vapor
import HTTP

@testable import KeepinServer

class UserControllerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        try? config?.setup()
        try? drop?.setup()
    }

    func testRegisterRequestSuccess() throws {
        let randomNumber = Int(arc4random_uniform(1000000000))
        let user = "User\(String(randomNumber))"

        let bodyJSON: JSON = [
            "username": .string(user),
            "email": "user3rfrg@fr.fr",
            "password": "usertest"
        ]

        let body = bodyJSON.makeBody()
        let res = try drop?.request(
            .post, "/api/v1/register",
            query: [:],
            ["content-type":"application/json"],
            body,
            through: []
        )

        guard res?.status == .ok else {
            XCTFail()
            return
        }
    }
}



