//
//  LogChannelLocation + customRaw.swift
//
//
//  Created by Ky Leggiero on 2023-06-08.
//

import Foundation
import FunctionTools



private let errorMessage_logNonRawMessageToRawLocation = "<<SimpleLogging: Attempted to log non-raw message to raw location>>"



/// Log to a function, so you can implement some custom logging location where you assemble it yourself.
///
/// The function is passed completely unrendered log message components. See the documentation for `RawLogMessage` for more info.
///
/// Log channels may choose to pre-filter messages before that function is called.
public struct CustomRawLogChannelLocation: LogChannelLocation {
    
    /// API users give us this to tell us where/how to log messages
    private let logger: Callback<RawLogMessage>
    
    
    /// Create a new custom log channel location
    ///
    /// The function is passed the raw data about what to log.
    /// Log channels may choose to pre-filter messages before that function is called.
    ///
    /// - Parameter logger: Passed the raw, unrendered log message & metadata
    public init(loggingTo logger: @escaping Callback<RawLogMessage>) {
        self.logger = logger
    }
    
    
    public func append(_ message: LogMessageProtocol, options: LoggingOptions) {
        if let message = message as? RawLogMessage {
            logger(message)
        }
        else {
            assertionFailure(
                """
                When logging to a raw location, `message` must be a `RawLogMessage`.
                Instead, this was received: \(type(of: message))

                In prodiction, this will be logged as a rendered log line, along with info about this failure, with `error` severity to Swift's `print` destination.
                Production lines will have the following text inside them:
                \(errorMessage_logNonRawMessageToRawLocation)

                The entire rendered log line (including this error and the original severity) will be placed in the message location of the log line.
                Because `RawLogMessage` is the only built-in message which knows its code location, a dummy code location will be used instead, with a file path of `"error"`, a function name of `"error"`, and a line number of `0xbad_c0de` (`195936478`).
                """
            )
            
            print(
                RawLogMessage(
                    dateLogged: message.dateLogged,
                    severity: .error,
                    codeLocation: CodeLocation(fullFilePath: "error", functionIdentifier: "error", lineNumber: 0xbad_c0de),
                    message: "\t \(errorMessage_logNonRawMessageToRawLocation)\t \(message.entireRenderedLogLine(options: options))"
                )
                .entireRenderedLogLine(options: options))
         }
    }
}



public extension UnreliableLogChannelLocation where Self == CustomRawLogChannelLocation {
    
    /// Log to a function, so you can implement some custom logging location where you assemble it yourself.
    ///
    /// The function is passed completely unrendered log message components. See the documentation for `RawLogMessage` for more info.
    ///
    /// Log channels may choose to pre-filter messages before that function is called.
    ///
    /// - Parameter logger: Passed the raw, unrendered log message & metadata
    static func customRaw(loggingTo logger: @escaping Callback<RawLogMessage>) -> Self {
        .init(loggingTo: logger)
    }
}



public extension LogChannel where Location == CustomRawLogChannelLocation {
    /// Log to a function, so you can implement some custom logging location where you assemble it yourself.
    /// 
    /// The function is passed completely unrendered log message components. See the documentation for `RawLogMessage` for more info.
    /// 
    /// Log channels may choose to pre-filter messages before that function is called.
    ///
    /// - Parameters:
    ///   - name:                  The human-readable name of the channel
    ///   - lowestAllowedSeverity: _optional_ - The lowest severity which will appear in this channel's logs. Defaults to `.defaultFilter`
    ///   - logSeverityNameStyle:  _optional_ - The style of the severity names that appear in the log. Defaults to `.default`
    ///   - logger:                Passed the raw, unrendered log message & metadata
    func customRaw(
        name: String,
        lowestAllowedSeverity: LogSeverity,
        logSeverityNameStyle: SeverityNameStyle = .default,
        logger: @escaping Callback<RawLogMessage>)
    -> Self {
        .init(name: name,
              location: Location(loggingTo: logger),
              lowestAllowedSeverity: lowestAllowedSeverity,
              logSeverityNameStyle: logSeverityNameStyle)
    }
    
    
    /// Log to a function, so you can implement some custom logging location where you assemble it yourself.
    ///
    /// The function is passed completely unrendered log message components. See the documentation for `RawLogMessage` for more info.
    ///
    /// Log channels may choose to pre-filter messages before that function is called.
    ///
    /// - Parameters:
    ///   - name:                  The human-readable name of the channel
    ///   - severityFilter:        _optional_ - The filter which decides which messages appear in this channel's logs. Defaults to `.default`
    ///   - logSeverityNameStyle:  _optional_ - The style of the severity names that appear in the log. Defaults to `.default`
    ///   - logger:                Passed the raw, unrendered log message & metadata
    static func customRaw(
        name: String,
        severityFilter: LogSeverityFilter = .default,
        logSeverityNameStyle: SeverityNameStyle = .default,
        logger: @escaping Callback<RawLogMessage>)
    -> Self {
        .init(name: name,
                  location: Location(loggingTo: logger),
                  severityFilter: severityFilter,
                  logSeverityNameStyle: logSeverityNameStyle)
    }
}
