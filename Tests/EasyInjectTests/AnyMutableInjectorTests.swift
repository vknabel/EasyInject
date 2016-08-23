//
//  AnyMutableInjectorTests.swift
//  EasyInject
//
//  Created by Valentin Knabel on 23.08.16.
//
//

import XCTest
@testable import EasyInject

class AnyMutableInjectorTests: XCTestCase, LinuxTestCase, InjectorTestCase, MutableInjectorTestCase {
    var newInjector: () -> AnyInjector<String> {
        return { AnyInjector(injector: LazyInjector()) }
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
