//
//  ComposedInjectorTests.swift
//  EasyInject
//
//  Created by Valentin Knabel on 23.08.16.
//
//

import XCTest
@testable import EasyInject

class ComposedInjectorTests: XCTestCase, InjectorTestCase, MutableInjectorTestCase {
    var newInjector: () -> ComposedInjector<String> {
        return { LazyInjector().compose(StrictInjector()) }
    }

    func testInjectorConformance() {
        runInjectorTestCase()
    }

    func testMutableInjectorConformance() {
        runMutableInjectorTestCase()
    }
}

