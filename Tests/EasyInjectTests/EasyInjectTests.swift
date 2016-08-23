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
    var entries: [XCTestCaseEntry] = []
    entries += StrictInjectorTests.allTests
    entries += LazyInjectorTests.allTests
    entries += GlobalInjectorTests.allTests
    entries += ComposedInjectorTests.allTests
    entries += AnyInjectorTests.allTests
    return entries
}
#endif
