#if !os(watchOS)
import XCTest

import ActionsTests

var tests = [XCTestCaseEntry]()
tests += ActionsTests.__allTests()

XCTMain(tests)
#endif
