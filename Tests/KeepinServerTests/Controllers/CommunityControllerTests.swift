//
//  CommunityControllerTests.swift
//  KeepinServerTests
//
//  Created by Rplay on 20/01/2018.
//

import Foundation
import XCTest
import Vapor
import HTTP

@testable import KeepinServer

class CommunityControllerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        try? config?.setup()
        try? drop?.setup()
    }

    func testSearchRequestSuccess() throws {
        let search = "test"
        let res = try drop?.request(.get, "/api/v1/communities/search?name=\(search)&limit=5")
        guard let bytes = res?.body.bytes else {
            XCTFail()
            return
        }

        let json = try JSON(bytes: bytes)
        let communitiesNames = json.wrapped.array?.map({(data: StructuredData) -> String? in
            return data.object?["name"]?.string
        })

        guard let names = communitiesNames else {
            XCTFail()
            return
        }

        let namesContainsSearchValue = names.reduce(true, { result, name in
            guard result else { return result }
            return name?.range(of: search) != nil
        })

        XCTAssertTrue(names.count == 5)
        XCTAssertTrue(namesContainsSearchValue)
        XCTAssertTrue(res?.status == .ok)
    }

    func testSearchRequestNotFound() throws {
        let search = "nowayicallmycommunitylikethatintest"
        let res = try drop?.request(.get, "/api/v1/communities/search?name=\(search)")
        XCTAssertTrue(res?.status == .notFound)
    }

    func testCreateRequestSuccess() throws {
        let name = String.randomText(length: 10)
        guard let token = try drop?.createJwtToken("rplay") else {
            XCTFail()
            return
        }

        let bodyJSON: JSON = [
            "name": .string(name),
        ]

        let headers: [HeaderKey: String] = [
            "authorization": "Bearer \(token)",
            "content-type":"application/json"
        ]

        let body = bodyJSON.makeBody()
        let res = try drop?.request(
            .post, "/api/v1/communities",
            query: [:],
            headers,
            body,
            through: []
        )

        guard res?.status == .ok else {
            XCTFail()
            return
        }
    }
}


