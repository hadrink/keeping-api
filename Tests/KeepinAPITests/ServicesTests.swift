//
//  ServicesTests.swift
//  KeepinAPI
//
//  Created by Rplay on 01/10/2017.
//

import Foundation
import XCTest
@testable import MongoKitten
@testable import KeepinAPI

class ServicesTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    func testCreate() {
        print("tests")
        let userDocument: Document = ["username":  "jean"]
        UsersServices.create(document: userDocument)

        do {
            guard let documents = try UsersServices.collection?.find(["username":  "jean"]) else {
                XCTFail()
                return
            }

            for document in documents {
                XCTAssertNotNil(document)
            }
        } catch let e {
            print(e)
            XCTFail()
        }
    }
}
