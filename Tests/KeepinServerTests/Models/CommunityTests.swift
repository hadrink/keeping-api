//
//  Community.swift
//  KeepinServerTests
//
//  Created by Rplay on 14/01/2018.
//

import Foundation
import XCTest
import Vapor

@testable import KeepinServer

class CommunityTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testGetCommunities() {
        let community1 = Community(name: "swift")
        let community2 = Community(name: "java")

        let communities = [community1, community2]
        do {
            _ = try Community.get(communities: communities)
            XCTAssert(true)
        } catch let e {
            print(e)
            XCTFail()
        }
    }

    func testSearchCommunitiesByNameSuccess() throws {
        let value = "test"
        let communities = try Community.searchCommunitiesByName(from: value)
        XCTAssertTrue(try communities.makeResponse().status == .ok)
    }

    func testSearchCommunitiesByNameNotFound() throws {
        let value = "nowayicallmycommunitylikethatintest"
        do {
            _ = try Community.searchCommunitiesByName(from: value)
        } catch let e as AbortError {
            XCTAssertTrue(e.status == .notFound)
        }
    }
}

