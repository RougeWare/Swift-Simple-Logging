//
//  LogLocation.customRaw tests.swift
//  
//
//  Created by Ky on 2022-01-31.
//

import XCTest
import SimpleLogging



private let dateRaw = #"\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [+-]\d{4}"#
private let dateEpoch = #"2001-01-01 00:00:00 \+0000"#



final class LogLocation_customRaw_Tests: XCTestCase {
    
    
    func testRawLog() throws {
        
        var counter: UInt = 0
        var loggedLines: [String] = []
        
        let testLogChannel = try LogChannel(
            name: "Log Raw Test",
            location: .customRaw(logger: { result in
                counter += 1
                loggedLines.append(
                    "\(counter):: date: \(result.dateLogged), severity: \(result.severity), codeLocation: \(result.codeLocation) message: \(result.message), also: \(result.additionalParameters?.description ?? "nothing")"
                )
            })
        )
        LogManager.defaultChannels = [testLogChannel]
        
        #sourceLocation(file: "LogLocation.customRaw tests.testRawLog.swift", line: 1)
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
        
        log(message: RawLogMessage(dateLogged: Date(timeIntervalSinceReferenceDate: 0),
                                   severity: .fatal,
                                   locationFullFilePath: "Untitled.txt",
                                   locationFunctionIdentifier: "Nunction Fame",
                                   locationLineNumber: 42,
                                   message: "Testing raw log messages",
                                   additionalParameters: ["foo": "bar", "baz": false]))
        #sourceLocation()
        
        
        let expectedRegexes = #"""
        1:: date: \#(dateRaw), severity: LogSeverity\(severityValue: 3\.0, name: \(short: "i", long: "Info", emoji: "ℹ️"\)\), codeLocation: LogLocation\.customRaw tests\.testRawLog\.swift:3 testRawLog\(\) message: This message is informative, also: nothing
        2:: date: \#(dateRaw), severity: LogSeverity\(severityValue: 4\.0, name: \(short: "w", long: "Warning", emoji: "⚠️"\)\), codeLocation: LogLocation\.customRaw tests\.testRawLog\.swift:4 testRawLog\(\) message: This message is a warning, also: nothing
        3:: date: \#(dateRaw), severity: LogSeverity\(severityValue: 5\.0, name: \(short: "e", long: "Error", emoji: "🆘"\)\), codeLocation: LogLocation\.customRaw tests\.testRawLog\.swift:5 testRawLog\(\) message: This message is erroneous, also: nothing
        4:: date: \#(dateRaw), severity: LogSeverity\(severityValue: 5\.0, name: \(short: "e", long: "Error", emoji: "🆘"\)\), codeLocation: LogLocation\.customRaw tests\.testRawLog\.swift:6 testRawLog\(\) message: This error is logged but never thrown, also: nothing
        5:: date: \#(dateRaw), severity: LogSeverity\(severityValue: 5\.0, name: \(short: "e", long: "Error", emoji: "🆘"\)\), codeLocation: LogLocation\.customRaw tests\.testRawLog\.swift:7 testRawLog\(\) message: This error is logged but never thrown  \tThis is a message about the error which was logged but never thrown, also: nothing
        6:: date: \#(dateRaw), severity: LogSeverity\(severityValue: 5\.0, name: \(short: "e", long: "Error", emoji: "🆘"\)\), codeLocation: LogLocation\.customRaw tests\.testRawLog\.swift:8 testRawLog\(\) message: This error is only thrown from inside a test function, also: nothing
        7:: date: \#(dateRaw), severity: LogSeverity\(severityValue: 1000\.0, name: \(short: "f", long: "Fatal", emoji: "🚨"\)\), codeLocation: LogLocation\.customRaw tests\.testRawLog\.swift:10 testRawLog\(\) message: This message is fatal, also: nothing
        8:: date: \#(dateEpoch), severity: LogSeverity\(severityValue: 1000\.0, name: \(short: "f", long: "Fatal", emoji: "🚨"\)\), codeLocation: Untitled.txt:42 Nunction Fame message: Testing raw log messages, also: (?:\[\"baz\": false, \"foo\": \"bar\"\]|\[\"foo\": \"bar\", \"baz\": false\])
        """#
            .split(separator: "\n")
            .map(String.init)
            .map(NSRegularExpression.init)
        
        XCTAssertEqual(expectedRegexes.count, loggedLines.count)
        
        
        for (expected, actual) in zip(expectedRegexes, loggedLines) {
            XCTAssertEqual(1,
                           expected.numberOfMatches(
                               in: actual,
                               options: .anchored,
                               range: NSRange(location: 0, length: actual.utf16.count)),
                            """
                            Expected log line:
                            \(expected.pattern)
                            
                            Actual log line:
                            \(actual)
                            """)
        }
    }
    
    
    
    
    static var allTests = [
        ("testRawLog", testRawLog),
    ]
}
