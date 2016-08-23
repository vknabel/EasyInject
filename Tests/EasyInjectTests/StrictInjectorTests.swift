//
//  StrictInjectorTests.swift
//  EasyInject
//
//  Created by Valentin Knabel on 19.08.16.
//
//

import XCTest
@testable import EasyInject

class StrictInjectorTests: XCTestCase, LinuxTestCase, InjectorTestCase, MutableInjectorTestCase {
    var newInjector: () -> StrictInjector<String> {
        return StrictInjector.init
    }

    static var allTests = [
        ("testInjectorConformance", testInjectorConformance),
        ("testMutableInjectorConformance", testMutableInjectorConformance),
        ("testStrictnessOfProvide", testStrictnessOfProvide),
        ("testStrictnessOfProviding", testStrictnessOfProviding),
        ("testExecuteExactlyOnceForProvide", testExecuteExactlyOnceForProvide),
        ("testExecuteExactlyOnceForProviding", testExecuteExactlyOnceForProviding)
    ]

    func testInjectorConformance() {
        runInjectorTestCase()
    }

    func testMutableInjectorConformance() {
        runMutableInjectorTestCase()
    }

    func testStrictnessOfProvide() {
        var inj = StrictInjector<String>()
        let key = "my strict key"
        var isStrict = false
        inj.provide(key: key) { _ in
            isStrict = true
            return 4
        }
        XCTAssertTrue(isStrict, "StrictInjector.provide(key:usingFactory:) is not strict. Context:"
            + "\n\t injector: \(inj)"
            + "\n\t key: \(key)")
    }

    func testStrictnessOfProviding() {
        let inj = StrictInjector<String>()
        let key = "my strict key"
        var isStrict = false
        _ = inj.providing(key: key) { _ in
            isStrict = true
            return 4
        }
        XCTAssertTrue(isStrict, "StrictInjector.providing(key:usingFactory:) is not strict for context:"
            + "\n\t injector: \(inj)"
            + "\n\t key: \(key)")
    }

    func testExecuteExactlyOnceForProvide() {
        var inj = StrictInjector<String>()
        let key = "my strict key"
        var times = 0
        inj.provide(key: key, usingFactory: { _ in
            times += 1
            return 5
        })
        XCTAssertEqual(times, 1, "StrictInjector.provide(key:usingFactory:) executes factory not exactly once context:"
            + "\n\t injector: \(inj)"
            + "\n\t key: \(key)")
    }

    func testExecuteExactlyOnceForProviding() {
        let inj = StrictInjector<String>()
        let key = "my strict key"
        var times = 0
        _ = inj.providing(key: key, usingFactory: { _ in
            times += 1
            return 5
        })
        XCTAssertEqual(times, 1, "StrictInjector.providing(key:usingFactory:) executes factory not exactly once context:"
            + "\n\t injector: \(inj)"
            + "\n\t key: \(key)")
    }

}
