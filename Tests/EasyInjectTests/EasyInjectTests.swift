//
//  InjectorConformanceTests.swift
//  EasyInject
//
//  Created by Valentin Knabel on 19.08.16.
//
//

import XCTest

#if os(Linux)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(StrictInjectorTests.allTests),
        testCase(LazyInjectorTests.allTests),
        testCase(GlobalInjectorTests.allTests),
        testCase(ComposedInjectorTests.allTests),
        testCase(AnyInjectorTests.allTests)
    ]
}
#endif
