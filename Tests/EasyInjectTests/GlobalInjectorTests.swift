//
//  GlobalInjectorTests.swift
//  EasyInject
//
//  Created by Valentin Knabel on 23.08.16.
//
//

import XCTest
@testable import EasyInject

class GlobalInjectorTests: XCTestCase, LinuxTestCase, InjectorTestCase, MutableInjectorTestCase {
    var newInjector: () -> GlobalInjector<String> {
        return GlobalInjector.init
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
