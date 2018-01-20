//
//  CommnityServicesTests.swift
//  KeepinServicesTests
//
//  Created by Rplay on 20/01/2018.
//

import XCTest
@testable import MongoKitten
@testable import KeepinServices

class CommunityServicesTests: XCTestCase {
    var db: Database?
    var collection: MongoKitten.Collection?

    override func setUp() {
        super.setUp()

        self.db = try! KIDatabase.connect()
        self.collection = db?[KICollections.communities.rawValue]
    }

    func testSearchCommunitiesByNameSuccess() throws {
        let value = "test"
        let communities = try CommunityServices.searchCommunitiesByName(from: value)
        let found = communities.contains{String($0["name"]) == value }
        XCTAssertTrue(found)
    }

    func testSearchCommunitiesByNameFail() throws {
        let value = "nowayicallmycommunitylikethatintest"
        let communities = try CommunityServices.searchCommunitiesByName(from: value)
        let found = communities.contains{String($0["name"]) == "test" }
        XCTAssertFalse(found)
    }
}

