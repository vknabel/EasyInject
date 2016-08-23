//
//  InjectorTestCase.swift
//  EasyInject
//
//  Created by Valentin Knabel on 19.08.16.
//
//

import XCTest
@testable import EasyInject

protocol InjectorTestCase {
    associatedtype I: Injector
    var newInjector: () -> I { get }
}

extension Int : Providable { }
extension String : Error { }

private enum InjectorTestError: Error {
    case SomeError
}

extension InjectorTestCase where I.Key == String {
    func runInjectorTestCase() -> Void {
        testResolvingThrowsEmpty()
        testProvidingAndResolving()
        testProvidingAndResolvingRethrows()
        testProvidingTwoAndResolving()
        testProvidedKeysEmpty()
        testProvidedKeysAfterProvidingValue()
        testProvidedKeysAfterProvidingError()
        testProvidedKeyAfterRevoking()
        testProvidedKeysAfterRevokingNotProvided()
        testRevokingAfterProvidingValue()
    }

    func testResolvingThrowsEmpty() {
        let inj = newInjector()
        let key = "key does not exist"
        do {
            let errorValue = try inj.resolving(key: key)
            XCTFail("Injector.resolving(key:) did not throw InjectionError<String>.keyNotProvided(_):"
                + "\n\t try inj.resolving(key: \"\(key)\")"
                + "\n\t injector: \(inj)"
                + "\n\t returns: \(errorValue)")
        } catch let error as InjectionError<String> {
            switch error {
            case let .keyNotProvided(lhs) where lhs == key:
                // Expected
                return
            default:
                XCTFail("Injector.resolving(key:) did not throw InjectionError<String>.keyNotProvided(_):"
                    + "\n\t try inj.resolving(key: \"\(key)\")"
                    + "\n\t injector: \(inj)"
                    + "\n\t throwed: \(error)")
            }
        } catch {
            XCTFail()
        }
    }

    func testProvidingAndResolving() {
        let inj = newInjector()
        let key = "provided key"
        do {
            let newInj = inj.providing(key: key, usingFactory: { _ in 3 })
            guard let resolved = try newInj.resolving(key: key) as? Int else {
                return XCTFail("Injector.resolving(key:) not of the same type as provided:"
                    + "\n\t injector: \(inj)"
                    + "\n\t key: \(key)")
            }
            XCTAssertEqual(resolved, 3, "Injector.resolving(key:) not of the same value as provided:"
                + "\n\t injector: \(inj)"
                + "\n\t key: \(key)")
        } catch {
            XCTFail("Injector.resolving(key:) unexpectedly throws:"
                + "\n\t injector: \(inj)"
                + "\n\t key: \(key)")
        }
    }

    func testProvidingAndResolvingRethrows() {
        let inj = newInjector()
        let key = "throwing key"
        let throwed = InjectorTestError.SomeError
        do {
            let newInj = inj.providing(key: key, usingFactory: { _ in throw throwed })
            _ = try newInj.resolving(key: key)
            XCTFail("Injector.resolving(key:) did now throw as expected:"
                + "\n\t injector: \(inj)"
                + "\n\t key: \(key)")
        } catch let error as InjectionError<String> {
            switch error {
            case let .customError(caught as InjectorTestError):
                XCTAssertEqual(caught, throwed, "Injector.resolving(key:) did not throw the same error wrapped in InjectionError.customError(_):"
                    + "\n\t injector: \(inj)"
                    + "\n\t key: \(key)")
            default:
                XCTFail("Injector.resolving(key:) throwed an invalid error:"
                    + "\n\t injector: \(inj)"
                    + "\n\t key: \(key)"
                    + "\n\t error: \(error)")
            }
        } catch let caught as InjectorTestError where caught == throwed {
            XCTFail("Injector.resolving(key:) did not wrap throwed error in InjectionError.customError(_):"
                + "\n\t injector: \(inj)"
                + "\n\t key: \(key)"
                + "\n\t error: \(caught)")
        } catch {
            XCTFail("Injector.resolving(key:) throwed an unknown type:"
                + "\n\t injector: \(inj)"
                + "\n\t key: \(key)")
        }
    }

    func testProvidingTwoAndResolving() {
        let inj = newInjector()
        let firstKey = "first key"
        let secondKey = "second key"
        do {
            let newInj = inj
                .providing(key: firstKey, usingFactory: { _ in 1 })
                .providing(key: secondKey, usingFactory: { _ in 2 })

            let first = try newInj.resolving(key: firstKey) as! Int
            XCTAssertEqual(first, 1, "Injector.resolving(key:) does not return the first provided value correctly.")
            let second = try newInj.resolving(key: secondKey) as! Int
            XCTAssertEqual(second, 2, "Injector.resolving(key:) does not return the second provided value correctly.")
        } catch {
            XCTFail("Injector.resolving(key:) unexpectedly throws:"
                + "\n\t injector: \(inj)"
                + "\n\t firstKey: \(firstKey)"
                + "\n\t secondKey: \(secondKey)")
        }
    }

    func testProvidedKeysEmpty() {
        let inj = newInjector()
        XCTAssertEqual(inj.providedKeys, [])
    }

    func testProvidedKeysAfterProvidingValue() {
        var inj = newInjector()
        let key = "value key"
        inj = inj.providing(key: key, usingFactory: { _ in 1 })
        XCTAssertEqual(inj.providedKeys, [key])
    }

    func testProvidedKeysAfterProvidingError() {
        var inj = newInjector()
        let key = "error key"
        inj = inj.providing(key: key, usingFactory: { _ in throw "Thrown Error"})
        XCTAssertEqual(inj.providedKeys, [key])
    }

    func testProvidedKeyAfterRevoking() {
        var inj = newInjector()
        let key = "value key"
        inj = inj.providing(key: key, usingFactory: { _ in 1 }).revoking(key: key)
        XCTAssertEqual(inj.providedKeys, [])
    }

    func testProvidedKeysAfterRevokingNotProvided() {
        var inj = newInjector()
        let key = "not provided"
        inj = inj.revoking(key: key)
        XCTAssertEqual(inj.providedKeys, [])
    }

    func testRevokingAfterProvidingValue() {
        var inj = newInjector()
        let key = "value key"
        inj = inj.providing(key: key, usingFactory: { _ in 1 }).revoking(key: key)
        do {
            let result = try inj.resolving(key: key)
            XCTFail("Injector.resolving(key:) did not revoke value: \(result)")
        } catch let error as InjectionError<String> {
            XCTAssertEqual(error, InjectionError.keyNotProvided(key))
        } catch {
            XCTFail("Injector.resolving(key:) did throw wrong error after revoking: \(error)")
        }
    }
}
