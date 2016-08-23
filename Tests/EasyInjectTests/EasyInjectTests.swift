//
//  InjectorConformanceTests.swift
//  EasyInject
//
//  Created by Valentin Knabel on 19.08.16.
//
//

import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return StrictInjectorTests.allTests
        + LazyInjectorTests.allTests
        + GlobalInjectorTests.allTests
        + ComposedInjectorTests.allTests
        + AnyInjectorTests.allTests
}
#endif
