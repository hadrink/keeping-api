//
//  Linuxmain.swift
//  KeepinAPI
//
//  Created by Rplay on 18/01/2018.
//
import XCTest
@testable import KeepinServicesTests
@testable import KeepinServerTests

XCTMain([
    testCase(UserTests.allTests),
    testCase(ServicesTests.allTests),
    testCase(UsersServicesTests.allTests),
    testCase(ChatControllerTests.allTests),
    testCase(CommunityTests.allTests)
])
