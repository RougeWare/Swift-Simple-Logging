//
//  LogToFileTests.swift
//  
//
//  Created by Ben Leggiero on 2020-05-19.
//

import XCTest
import SimpleLogging



private let date = #"\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z"#



final class LogToFileTests: XCTestCase {
    
    static let tempLogFolderUrl = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent(Bundle.main.bundleIdentifier!)
        .appendingPathComponent("Logs")
        .appendingPathComponent("Test \(Date())")
    
    static let testFilePath: String = tempLogFolderUrl.appendingPathComponent("test.log", isDirectory: false).path
    
    
    override func setUpWithError() throws {
        
        print(Self.testFilePath)
        
        if FileManager.default.fileExists(atPath: Self.testFilePath) {
            try FileManager.default.removeItem(atPath: Self.testFilePath)
        }
    }
    
    
    override func tearDownWithError() throws {
        try FileManager.default.removeItem(atPath: Self.testFilePath)
        LogManager.resetDefaultChannels()
    }
    
    
    func testLogToFile() throws {
        let testLogChannel = try LogChannel(name: "Log File Test",
                                            location: .file(path: Self.testFilePath))
        LogManager.defaultChannels.append(testLogChannel)
        
        log(verbose: "This message is verbose")
        log(debug: "This message is for debugging")
        log(info: "This message is informative")
        log(warning: "This message is a warning")
        log(error: "This message is erroneous")
        log(error: TestError.neverThrown)
        log(error: TestError.neverThrown, "This is a message about the error which was logged but never thrown")
        XCTAssertEqual(log(errorIfThrows: try alwaysThrows(), backup: 17), 17)
        XCTAssertEqual(log(errorIfThrows: neverThrows(42), backup: 5), 42)
        log(fatal: "This message is fatal")
        
        let testFileContents = try String(contentsOfFile: Self.testFilePath)
        
        let expectedFileContentsRegex = NSRegularExpression(wholeStringPattern: #"""
        \#(date) ℹ️ LogToFileTests\.swift:50 testLogToFile\(\) \tThis message is informative
        \#(date) ⚠️ LogToFileTests\.swift:51 testLogToFile\(\) \tThis message is a warning
        \#(date) 🆘 LogToFileTests\.swift:52 testLogToFile\(\) \tThis message is erroneous
        \#(date) 🆘 LogToFileTests\.swift:53 testLogToFile\(\) \tThis error is logged but never thrown
        \#(date) 🆘 LogToFileTests\.swift:54 testLogToFile\(\) \tThis error is logged but never thrown  \tThis is a message about the error which was logged but never thrown
        \#(date) 🆘 LogToFileTests\.swift:55 testLogToFile\(\) \tThis error is only thrown from inside a test function
        \#(date) 🚨 LogToFileTests\.swift:57 testLogToFile\(\) \tThis message is fatal
        """#)
        
        XCTAssertEqual(785, testFileContents.utf16.count)
        
        XCTAssertEqual(1, expectedFileContentsRegex.numberOfMatches(
            in: testFileContents,
            options: .anchored,
            range: NSRange(location: 0, length: testFileContents.utf16.count)),
                       """
            Expected log file contents:
            \(expectedFileContentsRegex.pattern)

            Actual log file contents:
            \(testFileContents)
            """)
    }
    
    
    func testLogAllSeveritiesToFile() throws {
        let testLogChannel = try LogChannel(
            name: "Log File Test",
            location: .file(path: Self.testFilePath),
            severityFilter: .allowAll)
        LogManager.defaultChannels.append(testLogChannel)
        
        log(verbose: "This message is verbose")
        log(debug: "This message is for debugging")
        log(info: "This message is informative")
        log(warning: "This message is a warning")
        log(error: "This message is erroneous")
        log(error: TestError.neverThrown)
        log(error: TestError.neverThrown, "This is a message about the error which was logged but never thrown")
        XCTAssertEqual(log(errorIfThrows: try alwaysThrows(), backup: 17), 17)
        XCTAssertEqual(log(errorIfThrows: neverThrows(42), backup: 5), 42)
        log(fatal: "This message is fatal")
        
        let testFileContents = try String(contentsOfFile: Self.testFilePath)
        
        let expectedFileContentsRegex = NSRegularExpression(wholeStringPattern: #"""
        \#(date) 💬 LogToFileTests\.swift:94 testLogAllSeveritiesToFile\(\) \tThis message is verbose
        \#(date) 👩🏾‍💻 LogToFileTests\.swift:95 testLogAllSeveritiesToFile\(\) \tThis message is for debugging
        \#(date) ℹ️ LogToFileTests\.swift:96 testLogAllSeveritiesToFile\(\) \tThis message is informative
        \#(date) ⚠️ LogToFileTests\.swift:97 testLogAllSeveritiesToFile\(\) \tThis message is a warning
        \#(date) 🆘 LogToFileTests\.swift:98 testLogAllSeveritiesToFile\(\) \tThis message is erroneous
        \#(date) 🆘 LogToFileTests\.swift:99 testLogAllSeveritiesToFile\(\) \tThis error is logged but never thrown
        \#(date) 🆘 LogToFileTests\.swift:100 testLogAllSeveritiesToFile\(\) \tThis error is logged but never thrown  \tThis is a message about the error which was logged but never thrown
        \#(date) 🆘 LogToFileTests\.swift:101 testLogAllSeveritiesToFile\(\) \tThis error is only thrown from inside a test function
        \#(date) 🚨 LogToFileTests\.swift:103 testLogAllSeveritiesToFile\(\) \tThis message is fatal
        """#)
        
        XCTAssertEqual(1102, testFileContents.utf16.count)
        
        XCTAssertEqual(1, expectedFileContentsRegex.numberOfMatches(
            in: testFileContents,
            options: .anchored,
            range: NSRange(location: 0, length: testFileContents.utf16.count)),
                        """
            Expected log file contents:
            \(expectedFileContentsRegex.pattern)

            Actual log file contents:
            \(testFileContents)
            """)
    }
    
    
    func testLogOnlyCriticalSeveritiesToFile() throws {
        let testLogChannel = try LogChannel(name: "Log File Test",
                                            location: .file(path: Self.testFilePath),
                                            lowestAllowedSeverity: .critical)
        LogManager.defaultChannels.append(testLogChannel)
        
        log(verbose: "This message is verbose")
        log(debug: "This message is for debugging")
        log(info: "This message is informative")
        log(warning: "This message is a warning")
        log(error: "This message is erroneous")
        log(error: TestError.neverThrown)
        log(error: TestError.neverThrown, "This is a message about the error which was logged but never thrown")
        XCTAssertEqual(log(errorIfThrows: try alwaysThrows(), backup: 17), 17)
        XCTAssertEqual(log(errorIfThrows: neverThrows(42), backup: 5), 42)
        log(fatal: "This message is fatal")
        
        let testFileContents = try String(contentsOfFile: Self.testFilePath)
        
        let expectedFileContentsRegex = NSRegularExpression(wholeStringPattern: #"""
        \#(date) 🆘 LogToFileTests\.swift:145 testLogOnlyCriticalSeveritiesToFile\(\) \tThis message is erroneous
        \#(date) 🆘 LogToFileTests\.swift:146 testLogOnlyCriticalSeveritiesToFile\(\) \tThis error is logged but never thrown
        \#(date) 🆘 LogToFileTests\.swift:147 testLogOnlyCriticalSeveritiesToFile\(\) \tThis error is logged but never thrown  \tThis is a message about the error which was logged but never thrown
        \#(date) 🆘 LogToFileTests\.swift:148 testLogOnlyCriticalSeveritiesToFile\(\) \tThis error is only thrown from inside a test function
        \#(date) 🚨 LogToFileTests\.swift:150 testLogOnlyCriticalSeveritiesToFile\(\) \tThis message is fatal
        """#)
        
        XCTAssertEqual(708, testFileContents.utf16.count)
        
        XCTAssertEqual(1, expectedFileContentsRegex.numberOfMatches(
            in: testFileContents,
            options: [.anchored, .withoutAnchoringBounds],
            range: NSRange(location: 0, length: testFileContents.utf16.count)),
                       """
            Expected log file contents:
            \(expectedFileContentsRegex.pattern)

            Actual log file contents:
            \(testFileContents)
            """)
    }
    
    
    func testTwoChannelsToTheSameFile() throws {
        let testLogChannel = try LogChannel(
            name: "Log File Test",
            location: .file(path: Self.testFilePath),
            severityFilter: .allowAll)
        LogManager.defaultChannels = [testLogChannel, testLogChannel]
        
        log(verbose: "This message is verbose")
        log(debug: "This message is for debugging")
        log(info: "This message is informative")
        log(warning: "This message is a warning")
        log(error: "This message is erroneous")
        log(error: TestError.neverThrown)
        log(error: TestError.neverThrown, "This is a message about the error which was logged but never thrown")
        XCTAssertEqual(log(errorIfThrows: try alwaysThrows(), backup: 17), 17)
        XCTAssertEqual(log(errorIfThrows: neverThrows(42), backup: 5), 42)
        log(fatal: "This message is fatal")
        
        let testFileContents = try String(contentsOfFile: Self.testFilePath)
        
        let expectedFileContentsRegex = NSRegularExpression(wholeStringPattern: #"""
        \#(date) 💬 LogToFileTests\.swift:185 testTwoChannelsToTheSameFile\(\) \tThis message is verbose
        \#(date) 💬 LogToFileTests\.swift:185 testTwoChannelsToTheSameFile\(\) \tThis message is verbose
        \#(date) 👩🏾‍💻 LogToFileTests\.swift:186 testTwoChannelsToTheSameFile\(\) \tThis message is for debugging
        \#(date) 👩🏾‍💻 LogToFileTests\.swift:186 testTwoChannelsToTheSameFile\(\) \tThis message is for debugging
        \#(date) ℹ️ LogToFileTests\.swift:187 testTwoChannelsToTheSameFile\(\) \tThis message is informative
        \#(date) ℹ️ LogToFileTests\.swift:187 testTwoChannelsToTheSameFile\(\) \tThis message is informative
        \#(date) ⚠️ LogToFileTests\.swift:188 testTwoChannelsToTheSameFile\(\) \tThis message is a warning
        \#(date) ⚠️ LogToFileTests\.swift:188 testTwoChannelsToTheSameFile\(\) \tThis message is a warning
        \#(date) 🆘 LogToFileTests\.swift:189 testTwoChannelsToTheSameFile\(\) \tThis message is erroneous
        \#(date) 🆘 LogToFileTests\.swift:189 testTwoChannelsToTheSameFile\(\) \tThis message is erroneous
        \#(date) 🆘 LogToFileTests\.swift:190 testTwoChannelsToTheSameFile\(\) \tThis error is logged but never thrown
        \#(date) 🆘 LogToFileTests\.swift:190 testTwoChannelsToTheSameFile\(\) \tThis error is logged but never thrown
        \#(date) 🆘 LogToFileTests\.swift:191 testTwoChannelsToTheSameFile\(\) \tThis error is logged but never thrown  \tThis is a message about the error which was logged but never thrown
        \#(date) 🆘 LogToFileTests\.swift:191 testTwoChannelsToTheSameFile\(\) \tThis error is logged but never thrown  \tThis is a message about the error which was logged but never thrown
        \#(date) 🆘 LogToFileTests\.swift:192 testTwoChannelsToTheSameFile\(\) \tThis error is only thrown from inside a test function
        \#(date) 🆘 LogToFileTests\.swift:192 testTwoChannelsToTheSameFile\(\) \tThis error is only thrown from inside a test function
        \#(date) 🚨 LogToFileTests\.swift:194 testTwoChannelsToTheSameFile\(\) \tThis message is fatal
        \#(date) 🚨 LogToFileTests\.swift:194 testTwoChannelsToTheSameFile\(\) \tThis message is fatal
        """#)
        
        XCTAssertEqual(2252, testFileContents.utf16.count)
        
        XCTAssertEqual(1, expectedFileContentsRegex.numberOfMatches(
            in: testFileContents,
            options: .anchored,
            range: NSRange(location: 0, length: testFileContents.utf16.count)),
                       """
            Expected log file contents:
            \(expectedFileContentsRegex.pattern)

            Actual log file contents:
            \(testFileContents)
            """)
    }
    
    
    static var allTests = [
        ("testLogToFile", testLogToFile),
        ("testLogAllSeveritiesToFile", testLogAllSeveritiesToFile),
        ("testLogOnlyCriticalSeveritiesToFile", testLogOnlyCriticalSeveritiesToFile),
        ("testTwoChannelsToTheSameFile", testTwoChannelsToTheSameFile),
    ]
}



private enum TestError: String, Error {
    case neverThrown = "This error is logged but never thrown"
    case thrownFromInsideTestFunction = "This error is only thrown from inside a test function"
}



extension TestError: CustomStringConvertible {
    var description: String {
        return rawValue
    }
}



private func alwaysThrows() throws -> UInt {
    throw TestError.thrownFromInsideTestFunction
}


private func neverThrows(_ return: UInt) -> UInt { `return` }



private extension NSRegularExpression {
    convenience init(wholeStringPattern: String) {
        try! self.init(pattern: "^\(wholeStringPattern)$")
    }
}
