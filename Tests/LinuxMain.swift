import XCTest
@testable import EasyInject
import EasyInjectTests

var tests = [XCTestCaseEntry]()
tests += EasyInjectTests.allTests()
XCTMain(tests)
