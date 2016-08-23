//
//  AnyInjectorTests.swift
//  EasyInject
//
//  Created by Valentin Knabel on 23.08.16.
//
//

import XCTest
@testable import EasyInject

class AnyInjectorTests: XCTestCase, LinuxTestCase, InjectorTestCase, MutableInjectorTestCase {
    var newInjector: () -> AnyInjector<String> {
        return StrictInjector().erased
    }

    static var allTests = [
        ("testInjectorConformance", testInjectorConformance),
        ("testMutableInjectorConformance", testMutableInjectorConformance)
    ]

    func testInjectorConformance() {
        runInjectorTestCase()
    }

    func testMutableInjectorConformance() {
        runMutableInjectorTestCase()
    }
}

