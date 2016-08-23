//
//  GlobalInjectorTests.swift
//  EasyInject
//
//  Created by Valentin Knabel on 23.08.16.
//
//

import XCTest
@testable import EasyInject

class GlobalInjectorTests: XCTestCase, InjectorTestCase, MutableInjectorTestCase {
    var newInjector: () -> GlobalInjector<String> {
        return GlobalInjector.init
    }

    func testInjectorConformance() {
        runInjectorTestCase()
    }

    func testMutableInjectorConformance() {
        runMutableInjectorTestCase()
    }
}
