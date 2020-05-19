import XCTest

import SimpleLoggingTests

var tests = [XCTestCaseEntry]()
tests += LogToFileTests.allTests()
XCTMain(tests)
