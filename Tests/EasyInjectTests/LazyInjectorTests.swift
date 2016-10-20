//
//  LazyInjectorTests.swift
//  EasyInject
//
//  Created by Valentin Knabel on 22.08.16.
//
//

import XCTest
@testable import EasyInject

class LazyInjectorTests: XCTestCase, LinuxTestCase, InjectorTestCase, MutableInjectorTestCase {
    var newInjector: () -> LazyInjector<String> {
        return LazyInjector.init
    }

    static var allTests = [
        ("testInjectorConformance", testInjectorConformance),
        ("testMutableInjectorConformance", testMutableInjectorConformance),
        ("testLaziness", testLaziness),
        ("testCyclicDependencies", testCyclicDependencies)
    ]

    func testInjectorConformance() {
        runInjectorTestCase()
    }

    func testMutableInjectorConformance() {
        runMutableInjectorTestCase()
    }

    func testLaziness() {
        let nKey = Provider<String, Int>(for: "n")
        let nPlusOneKey = Provider<String, Int>(for: "n + 1")

        let inj = newInjector()
            .providing(3, for: nKey)
            .providing(for: nPlusOneKey, usingFactory: { inj in
                let n = try inj.resolve(from: nKey)
                return n + 1
            })
        do {
            let n = try inj.resolving(from: nKey)
            XCTAssertEqual(n, 3, "Injector.resolving(key:) not of the same value as provided:"
                + "\n\t injector: \(inj)"
                + "\n\t key: \(nKey)")

            let nPlusOne = try inj.resolving(from: nPlusOneKey)
            XCTAssertEqual(nPlusOne, 4, "Injector.resolving(key:) not of the same value as provided:"
                + "\n\t injector: \(inj)"
                + "\n\t key: \(nKey)")
        } catch {
            XCTFail("Injector.resolving(key:) unexpectedly throws:"
                + "\n\t injector: \(inj)"
                + "\n\t nKey: \(nKey)"
                + "\n\t nPlusOneKey: \(nPlusOneKey)"
                + "\n\t \(error)")
        }
    }

    func testCyclicDependencies() {
        let inj = newInjector()
        let recursiveKey = Provider<String, Int>(for: "recursion")
        do {
            let newInj = inj
                .providing(for: recursiveKey, usingFactory: { inj in
                let n = try inj.resolve(from: recursiveKey)
                return n + 1
            })
            let n = try newInj.resolving(from: recursiveKey)

            XCTFail("LazyInjector.resolving(from:) did not throw for cyclic dependencies"
                + "\n\t injector: \(inj)"
                + "\n\t key: \(recursiveKey)"
                + "\n\t returned: \(n)")
        } catch InjectionError<String>.cyclicDependency("recursion") {
            XCTAssertTrue(true)
        }
        catch {
            XCTFail("LazyInjector.resolving(key:) unexpectedly throws:"
                + "\n\t injector: \(inj)"
                + "\n\t \(error)")
        }
    }
}
