//
//  AnyInjectorTests.swift
//  EasyInject
//
//  Created by Valentin Knabel on 23.08.16.
//
//

import XCTest
@testable import EasyInject

class AnyInjectorTests: XCTestCase, InjectorTestCase, MutableInjectorTestCase {
    var newInjector: () -> AnyInjector<String> {
        return StrictInjector().erased
    }

    func testInjectorConformance() {
        runInjectorTestCase()
    }

    func testMutableInjectorConformance() {
        runMutableInjectorTestCase()
    }
}

