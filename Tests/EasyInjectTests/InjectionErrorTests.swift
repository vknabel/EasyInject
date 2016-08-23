//
//  InjectionErrorTests.swift
//  EasyInject
//
//  Created by Valentin Knabel on 23.08.16.
//
//

import XCTest
@testable import EasyInject

extension String: Providable { }

class InjectionErrorTests: XCTestCase, LinuxTestCase {

    static var allTests = [
        ("testEquatable", testEquatable)
    ]


    func testEquatable() {
        let error0: InjectionError<String> = .keyNotProvided("equal")
        XCTAssertTrue(error0 == error0)
        XCTAssertFalse(error0 == .keyNotProvided("not equal"))

        let error1: InjectionError<String> = .nonMatchingType(provided: "provided", expected: String.self)
        XCTAssertTrue(error1 == error1)
        XCTAssertTrue(error1 == .nonMatchingType(provided: "will be ignored", expected: String.self))
        XCTAssertFalse(error1 == .nonMatchingType(provided: "Int is not String", expected: Int.self))

        let error2: InjectionError<String> = .customError(InjectorTestError.SomeError)
        XCTAssertTrue(error2 == error2)
        XCTAssertTrue(error2 == .customError(error2))

        XCTAssertFalse(error0 == error1)
        XCTAssertFalse(error0 == error2)

        XCTAssertFalse(error1 == error0)
        XCTAssertFalse(error1 == error2)

        XCTAssertFalse(error2 == error0)
        XCTAssertFalse(error2 == error1)
    }
}
