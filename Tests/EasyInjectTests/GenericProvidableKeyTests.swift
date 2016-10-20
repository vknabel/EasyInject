//
//  GenericProvidableKeyTests.swift
//  EasyInject
//
//  Created by Valentin Knabel on 20.10.16.
//
//

import XCTest
@testable import EasyInject

class GenericProvidableKeyTests: XCTestCase, LinuxTestCase {
    static var allTests = [
        ("testName", testName),
        ("testEqual", testEqual)
    ]

    func testName() {
        let key = GenericProvidableKey<Any>(name: "key")
        XCTAssertEqual(key.name, "key")
    }

    func testEqual() {
        let key0 = GenericProvidableKey<Any>(name: "key")
        let key1 = GenericProvidableKey<Any>(name: "key")
        XCTAssertEqual(key0, key1)
    }

    func testStringLiteral() {
        let literal: GenericProvidableKey<Any> = "key"
        let manual = GenericProvidableKey<Any>(name: "key")
        XCTAssertEqual(literal, manual)
    }

    func testExtendedGraphemeClusterLiteral() {
        let key0 = GenericProvidableKey<Any>(name: "key")
        let key1 = GenericProvidableKey<Any>(extendedGraphemeClusterLiteral: "key")
        XCTAssertEqual(key0, key1)
    }

    func testUnicodeScalarLiteral() {
        let key0 = GenericProvidableKey<Any>(name: "key")
        let key1 = GenericProvidableKey<Any>(unicodeScalarLiteral: "key")
        XCTAssertEqual(key0, key1)
    }
}
