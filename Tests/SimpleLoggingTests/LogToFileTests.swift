//
//  LogToFileTests.swift
//  
//
//  Created by Ky Leggiero on 2020-05-19.
//

import XCTest
import SimpleLogging



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
        try? FileManager.default.removeItem(atPath: Self.testFilePath)
        LogManager.resetDefaultChannels()
    }
    
    
    func testLogToFile() throws {
        let testLogChannel = try LogChannel.file(atPath: Self.testFilePath)
        LogManager.defaultChannels.append(testLogChannel)
        
        XCTAssertEqual(testLogChannel.name, "test.log")
        
        #sourceLocation(file: "LogToFileTests.testLogToFile.swift", line: 1)
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
        #sourceLocation()
        
        let testFileContents = try String(contentsOfFile: Self.testFilePath)
        
        let expectedFileContentsRegex = NSRegularExpression(wholeStringPattern: #"""
        \#(date) ℹ️ LogToFileTests\.testLogToFile\.swift:3 testLogToFile\(\) \tThis message is informative
        \#(date) ⚠️ LogToFileTests\.testLogToFile\.swift:4 testLogToFile\(\) \tThis message is a warning
        \#(date) 🆘 LogToFileTests\.testLogToFile\.swift:5 testLogToFile\(\) \tThis message is erroneous
        \#(date) 🆘 LogToFileTests\.testLogToFile\.swift:6 testLogToFile\(\) \tThis error is logged but never thrown
        \#(date) 🆘 LogToFileTests\.testLogToFile\.swift:7 testLogToFile\(\) \tThis error is logged but never thrown  \tThis is a message about the error which was logged but never thrown
        \#(date) 🆘 LogToFileTests\.testLogToFile\.swift:8 testLogToFile\(\) \tThis error is only thrown from inside a test function
        \#(date) 🚨 LogToFileTests\.testLogToFile\.swift:10 testLogToFile\(\) \tThis message is fatal
        """#)
        
        XCTAssertEqual(877, testFileContents.utf16.count)
        
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
        let testLogChannel = try LogChannel.file(
            atPath: Self.testFilePath,
            name: "Log File Test",
            severityFilter: .allowAll)
        LogManager.defaultChannels.append(testLogChannel)
        
        #sourceLocation(file: "LogToFileTests.testLogAllSeveritiesToFile.swift", line: 1)
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
        #sourceLocation()
        
        let testFileContents = try String(contentsOfFile: Self.testFilePath)
        
        let expectedFileContentsRegex = NSRegularExpression(wholeStringPattern: #"""
        \#(date) 💬 LogToFileTests\.testLogAllSeveritiesToFile\.swift:1 testLogAllSeveritiesToFile\(\) \tThis message is verbose
        \#(date) 👩🏾‍💻 LogToFileTests\.testLogAllSeveritiesToFile\.swift:2 testLogAllSeveritiesToFile\(\) \tThis message is for debugging
        \#(date) ℹ️ LogToFileTests\.testLogAllSeveritiesToFile\.swift:3 testLogAllSeveritiesToFile\(\) \tThis message is informative
        \#(date) ⚠️ LogToFileTests\.testLogAllSeveritiesToFile\.swift:4 testLogAllSeveritiesToFile\(\) \tThis message is a warning
        \#(date) 🆘 LogToFileTests\.testLogAllSeveritiesToFile\.swift:5 testLogAllSeveritiesToFile\(\) \tThis message is erroneous
        \#(date) 🆘 LogToFileTests\.testLogAllSeveritiesToFile\.swift:6 testLogAllSeveritiesToFile\(\) \tThis error is logged but never thrown
        \#(date) 🆘 LogToFileTests\.testLogAllSeveritiesToFile\.swift:7 testLogAllSeveritiesToFile\(\) \tThis error is logged but never thrown  \tThis is a message about the error which was logged but never thrown
        \#(date) 🆘 LogToFileTests\.testLogAllSeveritiesToFile\.swift:8 testLogAllSeveritiesToFile\(\) \tThis error is only thrown from inside a test function
        \#(date) 🚨 LogToFileTests\.testLogAllSeveritiesToFile\.swift:10 testLogAllSeveritiesToFile\(\) \tThis message is fatal
        """#)
        
        XCTAssertEqual(1334, testFileContents.utf16.count)
        
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
        let testLogChannel = try LogChannel.file(
            atPath: Self.testFilePath,
            name: "Log File Test",
            lowestAllowedSeverity: .critical)
        LogManager.defaultChannels.append(testLogChannel)
        
        #sourceLocation(file: "LogToFileTests.testLogOnlyCriticalSeveritiesToFile.swift", line: 1)
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
        #sourceLocation()
        
        let testFileContents = try String(contentsOfFile: Self.testFilePath)
        
        let expectedFileContentsRegex = NSRegularExpression(wholeStringPattern: #"""
        \#(date) 🆘 LogToFileTests\.testLogOnlyCriticalSeveritiesToFile\.swift:5 testLogOnlyCriticalSeveritiesToFile\(\) \tThis message is erroneous
        \#(date) 🆘 LogToFileTests\.testLogOnlyCriticalSeveritiesToFile\.swift:6 testLogOnlyCriticalSeveritiesToFile\(\) \tThis error is logged but never thrown
        \#(date) 🆘 LogToFileTests\.testLogOnlyCriticalSeveritiesToFile\.swift:7 testLogOnlyCriticalSeveritiesToFile\(\) \tThis error is logged but never thrown  \tThis is a message about the error which was logged but never thrown
        \#(date) 🆘 LogToFileTests\.testLogOnlyCriticalSeveritiesToFile\.swift:8 testLogOnlyCriticalSeveritiesToFile\(\) \tThis error is only thrown from inside a test function
        \#(date) 🚨 LogToFileTests\.testLogOnlyCriticalSeveritiesToFile\.swift:10 testLogOnlyCriticalSeveritiesToFile\(\) \tThis message is fatal
        """#)
        
        XCTAssertEqual(879, testFileContents.utf16.count)
        
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
        let testLogChannel = try LogChannel.file(
            atPath: Self.testFilePath,
            name: "Log File Test",
            severityFilter: .allowAll)
        LogManager.defaultChannels = [testLogChannel, testLogChannel]
        
        #sourceLocation(file: "LogToFileTests.testTwoChannelsToTheSameFile.swift", line: 1)
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
        #sourceLocation()
        
        let testFileContents = try String(contentsOfFile: Self.testFilePath)
        
        let expectedFileContentsRegex = NSRegularExpression(wholeStringPattern: #"""
        \#(date) 💬 LogToFileTests\.testTwoChannelsToTheSameFile\.swift:1 testTwoChannelsToTheSameFile\(\) \tThis message is verbose
        \#(date) 💬 LogToFileTests\.testTwoChannelsToTheSameFile\.swift:1 testTwoChannelsToTheSameFile\(\) \tThis message is verbose
        \#(date) 👩🏾‍💻 LogToFileTests\.testTwoChannelsToTheSameFile\.swift:2 testTwoChannelsToTheSameFile\(\) \tThis message is for debugging
        \#(date) 👩🏾‍💻 LogToFileTests\.testTwoChannelsToTheSameFile\.swift:2 testTwoChannelsToTheSameFile\(\) \tThis message is for debugging
        \#(date) ℹ️ LogToFileTests\.testTwoChannelsToTheSameFile\.swift:3 testTwoChannelsToTheSameFile\(\) \tThis message is informative
        \#(date) ℹ️ LogToFileTests\.testTwoChannelsToTheSameFile\.swift:3 testTwoChannelsToTheSameFile\(\) \tThis message is informative
        \#(date) ⚠️ LogToFileTests\.testTwoChannelsToTheSameFile\.swift:4 testTwoChannelsToTheSameFile\(\) \tThis message is a warning
        \#(date) ⚠️ LogToFileTests\.testTwoChannelsToTheSameFile\.swift:4 testTwoChannelsToTheSameFile\(\) \tThis message is a warning
        \#(date) 🆘 LogToFileTests\.testTwoChannelsToTheSameFile\.swift:5 testTwoChannelsToTheSameFile\(\) \tThis message is erroneous
        \#(date) 🆘 LogToFileTests\.testTwoChannelsToTheSameFile\.swift:5 testTwoChannelsToTheSameFile\(\) \tThis message is erroneous
        \#(date) 🆘 LogToFileTests\.testTwoChannelsToTheSameFile\.swift:6 testTwoChannelsToTheSameFile\(\) \tThis error is logged but never thrown
        \#(date) 🆘 LogToFileTests\.testTwoChannelsToTheSameFile\.swift:6 testTwoChannelsToTheSameFile\(\) \tThis error is logged but never thrown
        \#(date) 🆘 LogToFileTests\.testTwoChannelsToTheSameFile\.swift:7 testTwoChannelsToTheSameFile\(\) \tThis error is logged but never thrown  \tThis is a message about the error which was logged but never thrown
        \#(date) 🆘 LogToFileTests\.testTwoChannelsToTheSameFile\.swift:7 testTwoChannelsToTheSameFile\(\) \tThis error is logged but never thrown  \tThis is a message about the error which was logged but never thrown
        \#(date) 🆘 LogToFileTests\.testTwoChannelsToTheSameFile\.swift:8 testTwoChannelsToTheSameFile\(\) \tThis error is only thrown from inside a test function
        \#(date) 🆘 LogToFileTests\.testTwoChannelsToTheSameFile\.swift:8 testTwoChannelsToTheSameFile\(\) \tThis error is only thrown from inside a test function
        \#(date) 🚨 LogToFileTests\.testTwoChannelsToTheSameFile\.swift:10 testTwoChannelsToTheSameFile\(\) \tThis message is fatal
        \#(date) 🚨 LogToFileTests\.testTwoChannelsToTheSameFile\.swift:10 testTwoChannelsToTheSameFile\(\) \tThis message is fatal
        """#)
        
        XCTAssertEqual(2740, testFileContents.utf16.count)
        
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
    
    
    func testLogToFunction() throws {
        
        var wholeLog = ""
        
        let testLogChannel = LogChannel.custom(
            name: "Log Function Test",
            severityFilter: .allowAll,
            logger: { wholeLog += $0 + "\n" })
        LogManager.defaultChannels = [testLogChannel]
        
        #sourceLocation(file: "LogToFileTests.testLogToFunction.swift", line: 1)
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
        #sourceLocation()
        
        
        let expectedFileContentsRegex = NSRegularExpression(wholeStringPattern: #"""
        \#(date) 💬 LogToFileTests\.testLogToFunction\.swift:1 testLogToFunction\(\) \tThis message is verbose
        \#(date) 👩🏾‍💻 LogToFileTests\.testLogToFunction\.swift:2 testLogToFunction\(\) \tThis message is for debugging
        \#(date) ℹ️ LogToFileTests\.testLogToFunction\.swift:3 testLogToFunction\(\) \tThis message is informative
        \#(date) ⚠️ LogToFileTests\.testLogToFunction\.swift:4 testLogToFunction\(\) \tThis message is a warning
        \#(date) 🆘 LogToFileTests\.testLogToFunction\.swift:5 testLogToFunction\(\) \tThis message is erroneous
        \#(date) 🆘 LogToFileTests\.testLogToFunction\.swift:6 testLogToFunction\(\) \tThis error is logged but never thrown
        \#(date) 🆘 LogToFileTests\.testLogToFunction\.swift:7 testLogToFunction\(\) \tThis error is logged but never thrown  \tThis is a message about the error which was logged but never thrown
        \#(date) 🆘 LogToFileTests\.testLogToFunction\.swift:8 testLogToFunction\(\) \tThis error is only thrown from inside a test function
        \#(date) 🚨 LogToFileTests\.testLogToFunction\.swift:10 testLogToFunction\(\) \tThis message is fatal
        
        """#)
        
        XCTAssertEqual(1172, wholeLog.utf16.count)
        
        XCTAssertEqual(1, expectedFileContentsRegex.numberOfMatches(
                        in: wholeLog,
                        options: .anchored,
                        range: NSRange(location: 0, length: wholeLog.utf16.count)),
                       """
            Expected log string:
            \(expectedFileContentsRegex.pattern)

            Actual log string:
            \(wholeLog)
            """)
    }
    
    
    static var allTests = [
        ("testLogToFile", testLogToFile),
        ("testLogAllSeveritiesToFile", testLogAllSeveritiesToFile),
        ("testLogOnlyCriticalSeveritiesToFile", testLogOnlyCriticalSeveritiesToFile),
        ("testTwoChannelsToTheSameFile", testTwoChannelsToTheSameFile),
        ("testLogToFunction", testLogToFunction),
    ]
}
