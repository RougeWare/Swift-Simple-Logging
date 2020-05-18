import XCTest
@testable import SimpleLogging

final class SimpleLoggingTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SimpleLogging().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
