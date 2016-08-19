//
//  MutableInjectorTestCase.swift
//  EasyInject
//
//  Created by Valentin Knabel on 19.08.16.
//
//

import XCTest
@testable import EasyInject

protocol MutableInjectorTestCase: InjectorTestCase {
    associatedtype I: MutableInjector
    var newInjector: () -> I { get }
}

extension MutableInjectorTestCase where I.Key == String {
    func runMutableInjectorTestCase() -> Void {
        testResolveThrowsEmpty()
    }

    func testResolveThrowsEmpty() {
        var inj = newInjector()
        let key = "key does not exist"
        do {
            let errorValue = try inj.resolve(key: key)
            XCTFail("Injector did not throw InjectionError<String>.keyNotProvided(_). Context"
                + "\n\t try inj.resolve(key: \"\(key)\")"
                + "\n\t injector: \(inj)"
                + "\n\t returns: \(errorValue)")
        } catch let error as InjectionError<String> {
            switch error {
            case let .keyNotProvided(lhs) where lhs == key:
                XCTAssertTrue(true, "")
            default:
                XCTFail("Injector did not throw InjectionError<String>.keyNotProvided(_). Context"
                    + "\n\t try inj.resolve(key: \"\(key)\")"
                    + "\n\t injector: \(inj)"
                    + "\n\t throwed: \(error)")
            }
        } catch {
            XCTFail()
        }
    }
}
