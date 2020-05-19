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
        log(fatal: "This message is fatal")
        
        let testFileContents = try String(contentsOfFile: Self.testFilePath)
        
        let expectedFileContentsRegex = try NSRegularExpression(pattern: #"""
        ^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z ℹ️ This message is informative
        \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z ⚠️ This message is a warning
        \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z 🆘 This message is erroneous
        \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z 🚨 This message is fatal$
        """#, options: [])
        
        XCTAssertEqual(214, testFileContents.utf16.count)
        
        XCTAssertEqual(1, expectedFileContentsRegex.numberOfMatches(in: testFileContents,
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
        log(fatal: "This message is fatal")
        
        let testFileContents = try String(contentsOfFile: Self.testFilePath)
        
        let expectedFileContentsRegex = try NSRegularExpression(pattern: #"""
        ^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z 🗣 This message is verbose
        \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z 👩🏾‍💻 This message is for debugging
        \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z ℹ️ This message is informative
        \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z ⚠️ This message is a warning
        \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z 🆘 This message is erroneous
        \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z 🚨 This message is fatal
        $
        """#.replacingOccurrences(of: "\n", with: "\\n"), options: [])
        
        XCTAssertEqual(329, testFileContents.utf16.count)
        
        XCTAssertEqual(1, expectedFileContentsRegex.numberOfMatches(in: testFileContents,
                                                                    options: .anchored,
                                                                    range: NSRange(location: 0, length: testFileContents.utf16.count)))
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
        log(fatal: "This message is fatal")
        
        let testFileContents = try String(contentsOfFile: Self.testFilePath)
        
        let expectedFileContentsRegex = try NSRegularExpression(pattern: #"""
        ^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z 🆘 This message is erroneous
        \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z 🚨 This message is fatal
        $
        """#, options: [])
        
        XCTAssertEqual(104, testFileContents.utf16.count)
        
        XCTAssertEqual(1, expectedFileContentsRegex.numberOfMatches(in: testFileContents,
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
        log(fatal: "This message is fatal")
        
        let testFileContents = try String(contentsOfFile: Self.testFilePath)
        
        let expectedFileContentsRegex = try NSRegularExpression(pattern: #"""
        ^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z 🗣 This message is verbose
        \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z 🗣 This message is verbose
        \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z 👩🏾‍💻 This message is for debugging
        \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z 👩🏾‍💻 This message is for debugging
        \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z ℹ️ This message is informative
        \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z ℹ️ This message is informative
        \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z ⚠️ This message is a warning
        \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z ⚠️ This message is a warning
        \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z 🆘 This message is erroneous
        \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z 🆘 This message is erroneous
        \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z 🚨 This message is fatal
        \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z 🚨 This message is fatal
        $
        """#.replacingOccurrences(of: "\n", with: "\\n"), options: [])
        
        XCTAssertEqual(658, testFileContents.utf16.count)
        
        XCTAssertEqual(1, expectedFileContentsRegex.numberOfMatches(in: testFileContents,
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
