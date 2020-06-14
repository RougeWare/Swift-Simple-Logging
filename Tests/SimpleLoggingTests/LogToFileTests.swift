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
        XCTAssertEqual(log(errorIfThrows: try alwaysThrows(), backup: 17), 17)
        XCTAssertEqual(log(errorIfThrows: neverThrows(42), backup: 5), 42)
        log(fatal: "This message is fatal")
        
        let testFileContents = try String(contentsOfFile: Self.testFilePath)
        
        let expectedFileContentsRegex = NSRegularExpression(wholeStringPattern: #"""
        \#(date) ℹ️ LogToFileTests\.swift:50 testLogToFile\(\) \tThis message is informative
        \#(date) ⚠️ LogToFileTests\.swift:51 testLogToFile\(\) \tThis message is a warning
        \#(date) 🆘 LogToFileTests\.swift:52 testLogToFile\(\) \tThis message is erroneous
        \#(date) 🆘 LogToFileTests\.swift:53 testLogToFile\(\) \tneverThrown
        \#(date) 🆘 LogToFileTests\.swift:54 testLogToFile\(\) \tthrownFromInsideTestFunction
        \#(date) 🚨 LogToFileTests\.swift:56 testLogToFile\(\) \tThis message is fatal
        """#)
        
        XCTAssertEqual(557, testFileContents.utf16.count)
        
        XCTAssertEqual(1, expectedFileContentsRegex.numberOfMatches(
            in: testFileContents,
            options: .anchored,
            range: NSRange(location: 0, length: testFileContents.utf16.count)))
    }
    
    
    func testLogAllSeveritiesToFile() throws {
        let testLogChannel = try LogChannel(name: "Log File Test",
                                            location: .file(path: Self.testFilePath),
                                            lowestAllowedSeverity: nil)
        LogManager.defaultChannels.append(testLogChannel)
        
        log(verbose: "This message is verbose")
        log(debug: "This message is for debugging")
        log(info: "This message is informative")
        log(warning: "This message is a warning")
        log(error: "This message is erroneous")
        log(error: TestError.neverThrown)
        XCTAssertEqual(log(errorIfThrows: try alwaysThrows(), backup: 17), 17)
        XCTAssertEqual(log(errorIfThrows: neverThrows(42), backup: 5), 42)
        log(fatal: "This message is fatal")
        
        let testFileContents = try String(contentsOfFile: Self.testFilePath)
        
        let expectedFileContentsRegex = NSRegularExpression(wholeStringPattern: #"""
        \#(date) 💬 LogToFileTests\.swift:84 testLogAllSeveritiesToFile\(\) \tThis message is verbose
        \#(date) 👩🏾‍💻 LogToFileTests\.swift:85 testLogAllSeveritiesToFile\(\) \tThis message is for debugging
        \#(date) ℹ️ LogToFileTests\.swift:86 testLogAllSeveritiesToFile\(\) \tThis message is informative
        \#(date) ⚠️ LogToFileTests\.swift:87 testLogAllSeveritiesToFile\(\) \tThis message is a warning
        \#(date) 🆘 LogToFileTests\.swift:88 testLogAllSeveritiesToFile\(\) \tThis message is erroneous
        \#(date) 🆘 LogToFileTests\.swift:89 testLogAllSeveritiesToFile\(\) \tneverThrown
        \#(date) 🆘 LogToFileTests\.swift:90 testLogAllSeveritiesToFile\(\) \tthrownFromInsideTestFunction
        \#(date) 🚨 LogToFileTests\.swift:92 testLogAllSeveritiesToFile\(\) \tThis message is fatal
        """#)
        
        XCTAssertEqual(858, testFileContents.utf16.count)
        
        XCTAssertEqual(1, expectedFileContentsRegex.numberOfMatches(
            in: testFileContents,
            options: .anchored,
            range: NSRange(location: 0, length: testFileContents.utf16.count))
        )
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
        XCTAssertEqual(log(errorIfThrows: try alwaysThrows(), backup: 17), 17)
        XCTAssertEqual(log(errorIfThrows: neverThrows(42), backup: 5), 42)
        log(fatal: "This message is fatal")
        
        let testFileContents = try String(contentsOfFile: Self.testFilePath)
        
        let expectedFileContentsRegex = NSRegularExpression(wholeStringPattern: #"""
        \#(date) 🆘 LogToFileTests\.swift:127 testLogOnlyCriticalSeveritiesToFile\(\) \tThis message is erroneous
        \#(date) 🆘 LogToFileTests\.swift:128 testLogOnlyCriticalSeveritiesToFile\(\) \tneverThrown
        \#(date) 🆘 LogToFileTests\.swift:129 testLogOnlyCriticalSeveritiesToFile\(\) \tthrownFromInsideTestFunction
        \#(date) 🚨 LogToFileTests\.swift:131 testLogOnlyCriticalSeveritiesToFile\(\) \tThis message is fatal
        """#)
        
        XCTAssertEqual(457, testFileContents.utf16.count)
        
        XCTAssertEqual(1, expectedFileContentsRegex.numberOfMatches(
            in: testFileContents,
            options: [.anchored, .withoutAnchoringBounds],
            range: NSRange(location: 0, length: testFileContents.utf16.count)))
    }
    
    
    func testTwoChannelsToTheSameFile() throws {
        let testLogChannel = try LogChannel(name: "Log File Test",
                                            location: .file(path: Self.testFilePath),
                                            lowestAllowedSeverity: nil)
        LogManager.defaultChannels = [testLogChannel, testLogChannel]
        
        log(verbose: "This message is verbose")
        log(debug: "This message is for debugging")
        log(info: "This message is informative")
        log(warning: "This message is a warning")
        log(error: "This message is erroneous")
        log(error: TestError.neverThrown)
        XCTAssertEqual(log(errorIfThrows: try alwaysThrows(), backup: 17), 17)
        XCTAssertEqual(log(errorIfThrows: neverThrows(42), backup: 5), 42)
        log(fatal: "This message is fatal")
        
        let testFileContents = try String(contentsOfFile: Self.testFilePath)
        
        let expectedFileContentsRegex = NSRegularExpression(wholeStringPattern: #"""
        \#(date) 💬 LogToFileTests\.swift:157 testTwoChannelsToTheSameFile\(\) \tThis message is verbose
        \#(date) 💬 LogToFileTests\.swift:157 testTwoChannelsToTheSameFile\(\) \tThis message is verbose
        \#(date) 👩🏾‍💻 LogToFileTests\.swift:158 testTwoChannelsToTheSameFile\(\) \tThis message is for debugging
        \#(date) 👩🏾‍💻 LogToFileTests\.swift:158 testTwoChannelsToTheSameFile\(\) \tThis message is for debugging
        \#(date) ℹ️ LogToFileTests\.swift:159 testTwoChannelsToTheSameFile\(\) \tThis message is informative
        \#(date) ℹ️ LogToFileTests\.swift:159 testTwoChannelsToTheSameFile\(\) \tThis message is informative
        \#(date) ⚠️ LogToFileTests\.swift:160 testTwoChannelsToTheSameFile\(\) \tThis message is a warning
        \#(date) ⚠️ LogToFileTests\.swift:160 testTwoChannelsToTheSameFile\(\) \tThis message is a warning
        \#(date) 🆘 LogToFileTests\.swift:161 testTwoChannelsToTheSameFile\(\) \tThis message is erroneous
        \#(date) 🆘 LogToFileTests\.swift:161 testTwoChannelsToTheSameFile\(\) \tThis message is erroneous
        \#(date) 🆘 LogToFileTests\.swift:162 testTwoChannelsToTheSameFile\(\) \tneverThrown
        \#(date) 🆘 LogToFileTests\.swift:162 testTwoChannelsToTheSameFile\(\) \tneverThrown
        \#(date) 🆘 LogToFileTests\.swift:163 testTwoChannelsToTheSameFile\(\) \tthrownFromInsideTestFunction
        \#(date) 🆘 LogToFileTests\.swift:163 testTwoChannelsToTheSameFile\(\) \tthrownFromInsideTestFunction
        \#(date) 🚨 LogToFileTests\.swift:165 testTwoChannelsToTheSameFile\(\) \tThis message is fatal
        \#(date) 🚨 LogToFileTests\.swift:165 testTwoChannelsToTheSameFile\(\) \tThis message is fatal
        """#)
        
        XCTAssertEqual(1764, testFileContents.utf16.count)
        
        XCTAssertEqual(1, expectedFileContentsRegex.numberOfMatches(
            in: testFileContents,
            options: .anchored,
            range: NSRange(location: 0, length: testFileContents.utf16.count)))
    }
    
    
    static var allTests = [
        ("testLogToFile", testLogToFile),
        ("testLogAllSeveritiesToFile", testLogAllSeveritiesToFile),
        ("testLogOnlyCriticalSeveritiesToFile", testLogOnlyCriticalSeveritiesToFile),
        ("testTwoChannelsToTheSameFile", testTwoChannelsToTheSameFile),
    ]
}



private enum TestError: Error {
    case neverThrown
    case thrownFromInsideTestFunction
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
