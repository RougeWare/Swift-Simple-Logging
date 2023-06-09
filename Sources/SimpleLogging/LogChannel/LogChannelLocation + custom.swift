//
//  LogChannelLocation + Swift.print.swift
//  SimpleLogging
//
//  Created by Ky Leggiero on 2021-05-30.
//

import Foundation
import FunctionTools




/// Log to a function, so you can implement some custom logging channel without defining a new `struct`.
public struct CustomLogChannelLocation: LogChannelLocation {
    
    /// API users give us this to tell us where/how to log messages
    private let logger: Callback<String>
    
    
    /// Create a new custom log channel location
    ///
    /// The function is passed the fully-rendered log line, like
    /// `"2020-11-20 05:26:49.178Z ⚠️ LogToFileTests.swift:144 testLogOnlyCriticalSeveritiesToFile()     This message is a warning"`
    ///
    /// - Parameter logger: Passed the fully-rendered log line
    init(loggingTo logger: @escaping Callback<String>) {
        self.logger = logger
    }
    
    
    public func append(_ message: LogMessageProtocol, options: LoggingOptions) {
        logger(message.entireRenderedLogLine(options: options))
    }
}



public extension UnreliableLogChannelLocation where Self == CustomLogChannelLocation {
    
    /// Log to a function, so you can implement some custom logging channel without defining a new `struct`.
    ///
    /// The function is passed the fully-rendered log line, like
    /// `"2020-11-20 05:26:49.178Z ⚠️ LogToFileTests.swift:144 testLogOnlyCriticalSeveritiesToFile()     This message is a warning"`
    ///
    /// - Parameter logger: Passed the fully-rendered log line
    static func custom(loggingTo logger: @escaping Callback<String>) -> Self {
        .init(loggingTo: logger)
    }
}



public extension LogChannel where Location == CustomLogChannelLocation {
    
    /// Log to a function, so you can implement some custom logging channel without defining a new `struct`.
    ///
    /// The function is passed the fully-rendered log line, like
    /// `"2020-11-20 05:26:49.178Z ⚠️ LogToFileTests.swift:144 testLogOnlyCriticalSeveritiesToFile()     This message is a warning"`
    ///
    /// - Parameters:
    ///   - logger: Passed the fully-rendered log line
    ///   - name:                  The human-readable name of the channel
    ///   - severityFilter:        _optional_ - The filter which decides which messages appear in this channel's logs. Defaults to allowing `info` and higher, since `info` is the lowest built-in severity which users might care about if they're looking at logs, but not debugging the code itself.
    ///   - logSeverityNameStyle:  _optional_ - The style of the severity names that appear in the log. Defaults to `.emoji`, so humans can more easily skim the log.
    static func custom(
        name: String,
        lowestAllowedSeverity: LogSeverity,
        logSeverityNameStyle: SeverityNameStyle = .default,
        logger: @escaping Callback<String>)
    -> Self {
        Self.init(name: name,
                  location: Location(loggingTo: logger),
                  lowestAllowedSeverity: lowestAllowedSeverity,
                  logSeverityNameStyle: logSeverityNameStyle)
    }
    
    
    /// Log to a function, so you can implement some custom logging channel without defining a new `struct`.
    ///
    /// The function is passed the fully-rendered log line, like
    /// `2020-11-20 05:26:49.178Z ⚠️ LogToFileTests.swift:144 testLogOnlyCriticalSeveritiesToFile()     This message is a warning`
    ///
    /// - Parameters:
    ///   - logger: Passed the fully-rendered log line
    ///   - name:                  The human-readable name of the channel
    ///   - severityFilter:        _optional_ - The filter which decides which messages appear in this channel's logs. Defaults to allowing `info` and higher, since `info` is the lowest built-in severity which users might care about if they're looking at logs, but not debugging the code itself.
    ///   - logSeverityNameStyle:  _optional_ - The style of the severity names that appear in the log. Defaults to `.emoji`, so humans can more easily skim the log.
    static func custom(
        name: String,
        severityFilter: LogSeverityFilter = .default,
        logSeverityNameStyle: SeverityNameStyle = .default,
        logger: @escaping Callback<String>)
    -> Self {
        Self.init(name: name,
                  location: Location(loggingTo: logger),
                  severityFilter: severityFilter,
                  logSeverityNameStyle: logSeverityNameStyle)
    }
}
