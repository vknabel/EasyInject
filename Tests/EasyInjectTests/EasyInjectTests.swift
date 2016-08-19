//
//  InjectorConformanceTests.swift
//  EasyInject
//
//  Created by Valentin Knabel on 19.08.16.
//
//

import XCTest
@testable import EasyInject

class EasyInjectTests: XCTestCase, InjectorTestCase {
    var newInjector: () -> StrictInjector<String> {
        return StrictInjector.init
    }

    static var allTests : [(String, (EasyInjectTests) -> () throws -> Void)] {
        return [
            //("testInjectorConformance", testInjectorConformance),
        ]
    }
}
