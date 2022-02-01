//
//  LogToFileTests.swift
//  
//
//  Created by Ben Leggiero on 2020-05-19.
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
        \#(date) ℹ️ LogToFileTests\.swift:46 testLogToFile\(\) \tThis message is informative
        \#(date) ⚠️ LogToFileTests\.swift:47 testLogToFile\(\) \tThis message is a warning
        \#(date) 🆘 LogToFileTests\.swift:48 testLogToFile\(\) \tThis message is erroneous
        \#(date) 🆘 LogToFileTests\.swift:49 testLogToFile\(\) \tThis error is logged but never thrown
        \#(date) 🆘 LogToFileTests\.swift:50 testLogToFile\(\) \tThis error is logged but never thrown  \tThis is a message about the error which was logged but never thrown
        \#(date) 🆘 LogToFileTests\.swift:51 testLogToFile\(\) \tThis error is only thrown from inside a test function
        \#(date) 🚨 LogToFileTests\.swift:53 testLogToFile\(\) \tThis message is fatal
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
        \#(date) 💬 LogToFileTests\.swift:90 testLogAllSeveritiesToFile\(\) \tThis message is verbose
        \#(date) 👩🏾‍💻 LogToFileTests\.swift:91 testLogAllSeveritiesToFile\(\) \tThis message is for debugging
        \#(date) ℹ️ LogToFileTests\.swift:92 testLogAllSeveritiesToFile\(\) \tThis message is informative
        \#(date) ⚠️ LogToFileTests\.swift:93 testLogAllSeveritiesToFile\(\) \tThis message is a warning
        \#(date) 🆘 LogToFileTests\.swift:94 testLogAllSeveritiesToFile\(\) \tThis message is erroneous
        \#(date) 🆘 LogToFileTests\.swift:95 testLogAllSeveritiesToFile\(\) \tThis error is logged but never thrown
        \#(date) 🆘 LogToFileTests\.swift:96 testLogAllSeveritiesToFile\(\) \tThis error is logged but never thrown  \tThis is a message about the error which was logged but never thrown
        \#(date) 🆘 LogToFileTests\.swift:97 testLogAllSeveritiesToFile\(\) \tThis error is only thrown from inside a test function
        \#(date) 🚨 LogToFileTests\.swift:99 testLogAllSeveritiesToFile\(\) \tThis message is fatal
        """#)
        
        XCTAssertEqual(1099, testFileContents.utf16.count)
        
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
        \#(date) 🆘 LogToFileTests\.swift:141 testLogOnlyCriticalSeveritiesToFile\(\) \tThis message is erroneous
        \#(date) 🆘 LogToFileTests\.swift:142 testLogOnlyCriticalSeveritiesToFile\(\) \tThis error is logged but never thrown
        \#(date) 🆘 LogToFileTests\.swift:143 testLogOnlyCriticalSeveritiesToFile\(\) \tThis error is logged but never thrown  \tThis is a message about the error which was logged but never thrown
        \#(date) 🆘 LogToFileTests\.swift:144 testLogOnlyCriticalSeveritiesToFile\(\) \tThis error is only thrown from inside a test function
        \#(date) 🚨 LogToFileTests\.swift:146 testLogOnlyCriticalSeveritiesToFile\(\) \tThis message is fatal
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
        \#(date) 💬 LogToFileTests\.swift:181 testTwoChannelsToTheSameFile\(\) \tThis message is verbose
        \#(date) 💬 LogToFileTests\.swift:181 testTwoChannelsToTheSameFile\(\) \tThis message is verbose
        \#(date) 👩🏾‍💻 LogToFileTests\.swift:182 testTwoChannelsToTheSameFile\(\) \tThis message is for debugging
        \#(date) 👩🏾‍💻 LogToFileTests\.swift:182 testTwoChannelsToTheSameFile\(\) \tThis message is for debugging
        \#(date) ℹ️ LogToFileTests\.swift:183 testTwoChannelsToTheSameFile\(\) \tThis message is informative
        \#(date) ℹ️ LogToFileTests\.swift:183 testTwoChannelsToTheSameFile\(\) \tThis message is informative
        \#(date) ⚠️ LogToFileTests\.swift:184 testTwoChannelsToTheSameFile\(\) \tThis message is a warning
        \#(date) ⚠️ LogToFileTests\.swift:184 testTwoChannelsToTheSameFile\(\) \tThis message is a warning
        \#(date) 🆘 LogToFileTests\.swift:185 testTwoChannelsToTheSameFile\(\) \tThis message is erroneous
        \#(date) 🆘 LogToFileTests\.swift:185 testTwoChannelsToTheSameFile\(\) \tThis message is erroneous
        \#(date) 🆘 LogToFileTests\.swift:186 testTwoChannelsToTheSameFile\(\) \tThis error is logged but never thrown
        \#(date) 🆘 LogToFileTests\.swift:186 testTwoChannelsToTheSameFile\(\) \tThis error is logged but never thrown
        \#(date) 🆘 LogToFileTests\.swift:187 testTwoChannelsToTheSameFile\(\) \tThis error is logged but never thrown  \tThis is a message about the error which was logged but never thrown
        \#(date) 🆘 LogToFileTests\.swift:187 testTwoChannelsToTheSameFile\(\) \tThis error is logged but never thrown  \tThis is a message about the error which was logged but never thrown
        \#(date) 🆘 LogToFileTests\.swift:188 testTwoChannelsToTheSameFile\(\) \tThis error is only thrown from inside a test function
        \#(date) 🆘 LogToFileTests\.swift:188 testTwoChannelsToTheSameFile\(\) \tThis error is only thrown from inside a test function
        \#(date) 🚨 LogToFileTests\.swift:190 testTwoChannelsToTheSameFile\(\) \tThis message is fatal
        \#(date) 🚨 LogToFileTests\.swift:190 testTwoChannelsToTheSameFile\(\) \tThis message is fatal
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
    
    
    func testLogToFunction() throws {
        
        var wholeLog = ""
        
        let testLogChannel = try LogChannel(
            name: "Log Function Test",
            location: .custom { wholeLog += $0 + "\n" },
            severityFilter: .allowAll)
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
