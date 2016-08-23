//
//  LazyInjectorTests.swift
//  EasyInject
//
//  Created by Valentin Knabel on 22.08.16.
//
//

import XCTest
@testable import EasyInject

class LazyInjectorTests: XCTestCase, InjectorTestCase, MutableInjectorTestCase {
    var newInjector: () -> LazyInjector<String> {
        return LazyInjector.init
    }

    func testInjectorConformance() {
        runInjectorTestCase()
    }

    func testMutableInjectorConformance() {
        runMutableInjectorTestCase()
    }
}
