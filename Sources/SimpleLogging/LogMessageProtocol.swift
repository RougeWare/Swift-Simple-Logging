//
//  LogMessageProtocol.swift
//  SimpleLogging
//
//  Created by Ky Leggiero on 2020-05-18.
//

import Foundation



/// Something that can be logged
public protocol LogMessageProtocol {
    
    /// The line to be logged. This will automatically get any necessary prefix/suffix (e.g. severity, datetime, etc)
    var logLine: String { get }
    
    /// The severity of the log message
    var severity: LogSeverity { get }
    
    /// The date the message was originally logged
    var dateLogged: Date { get }
    
    
    /// The string that will be printed to the log, in its entirety.
    ///
    /// If you want your `Loggable` to look consistent, you should not override this. Instead, override `logLine`
    ///
    /// - Parameter options: _optional_ - Some options for how the log line should be rendered
    func entireRenderedLogLine(options: Options) -> String
}



public extension LogMessageProtocol {
    func entireRenderedLogLine(options: Options) -> String {
        "\(defaultDateFormatter.string(from: dateLogged)) \(severity.name(style: options.severityStyle)) \(logLine)"
    }
    
    
    /// The string that will be printed to the log, in its entirety.
    ///
    /// If you want your `Loggable` to look consistent, you should not override this. Instead, override `logLine`
    ///
    /// - Parameter options: _optional_ - Some options for how the log line should be rendered
    func entireRenderedLogLine() -> String {
        entireRenderedLogLine(options: .default)
    }
    
    
    
    /// Options to customize a log line
    typealias Options = LoggingOptions
}



/// Options to customize a log line
public struct LoggingOptions {
    
    /// The style of the severity part of a log line
    public let severityStyle: SeverityNameStyle
}



public extension LoggingOptions {
    /// The default logging options
    static let `default` = LoggingOptions(severityStyle: .default)
}



private let defaultDateFormatter: ISO8601DateFormatter = {
    let defaultDateFormatter = ISO8601DateFormatter()
    
    defaultDateFormatter.formatOptions = [
        .withYear, .withMonth, .withDay,
            .withDashSeparatorInDate,
        
        .withSpaceBetweenDateAndTime,
        
        .withTime, .withFractionalSeconds,
            .withColonSeparatorInTime, .withTimeZone,
    ]
    
    return defaultDateFormatter
}()
