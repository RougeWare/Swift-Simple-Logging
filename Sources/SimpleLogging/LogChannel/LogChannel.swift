//
//  LogChannel.swift
//  SimpleLogging
//
//  Created by Ky Leggiero on 2020-05-18.
//

import Foundation
import FunctionTools



/// A channel to which log messages can be sent
public protocol AnyLogChannel {
    
    /// Appends the given log message to this channel. If that can't be done, (for example, if the channel's location
    /// is a file on a read-only volume) a semantic error is thrown.
    ///
    /// - Note: The channel might choose to hold this log message in a buffer, for instance while it waits for a log file to be created
    ///
    /// - Parameter message: The message to append to this channel
    /// - Throws: a semantic error if the message can't be logged (for example, if the channel's location is a file on
    ///           a read-only volume)
    func append(_ message: LogMessageProtocol)
}



/// The channel to which to send log messages
public struct LogChannel<Location: UnreliableLogChannelLocation>: AnyLogChannel {
    
    /// The human-readable name of the log channel
    public let name: String
    
    /// The location of the log channel, to which log messages will be sent
    public let location: Location
    
    /// The severities which will be pushed to this channel. All others will be discarded entirely.
    public var severityFilter: LogSeverityFilter
    
    /// The style of the severity part of a log line in this channel
    @inline(__always)
    public var logSeverityNameStyle: SeverityNameStyle {
        get { options.severityStyle }
        
        @available(*, unavailable, message: """
            Ability to change a channel's log severity was removed in SimpleLogging 0.6 to reduce complexity and improve performance.
            See PR #17: https://github.com/RougeWare/Swift-Simple-Logging/pull/17
            """)
        set {  }
    }
    
    
    /// The logging options to use with each message
    private let options: LoggingOptions
    
    
    // MARK: Init
    
    /// Creates a new log channel with the given configuration. You usually don't need to use this; instead you can use the static functions like `.file` or `.swiftPrintDefault`.
    ///
    /// - Parameters:
    ///   - name:                  The human-readable name of the channel
    ///   - location:              The location where the logs are channeled to
    ///   - severityFilter:        _optional_ - The filter which decides which messages appear in this channel's logs. Defaults to `.default`
    ///   - logSeverityNameStyle:  _optional_ - The style of the severity names that appear in the log. Defaults to `.default`.
    public init(
        name: String,
        location: Location,
        severityFilter: LogSeverityFilter = .default,
        logSeverityNameStyle: SeverityNameStyle = .default)
    {
        self.name = name
        self.location = location
        self.severityFilter = severityFilter
        self.options = LoggingOptions(severityStyle: logSeverityNameStyle)
    }
    
    
    /// Creates a new log channel with the given configuration. You usually don't need to use this; instead you can use the static functions like `.file` or `.swiftPrintDefault`.
    ///
    /// - Parameters:
    ///   - name:                  The human-readable name of this channel
    ///   - location:              The location to which this channel sends its log messages
    ///   - lowestAllowedSeverity: _optional_ - The lowest severity which will appear in this channel's logs. Defaults to `defaultFilter`, since that's the lowest built-in severity which users might care about if they're looking at logs, but not debugging the code itself.
    ///   - logSeverityNameStyle:  _optional_ - The style of the severity names that appear in the log. Defaults to `.default`.
    public init(
        name: String,
        location: Location,
        lowestAllowedSeverity: LogSeverity,
        logSeverityNameStyle: SeverityNameStyle = .default)
    {
        self.init(
            name: name,
            location: location,
            severityFilter: .specificAndHigher(lowest: lowestAllowedSeverity),
            logSeverityNameStyle: logSeverityNameStyle)
    }
}



// MARK: - Appending

public extension LogChannel {
    
    /// Appends the given log message to this channel if the severity filter allows. If that can't be done, (for example, if the channel's location
    /// is a file on a read-only volume) a description of the problem, along with the logged message,is printed to the destination of Swift's built-in ``print(_:)``.
    ///
    /// Of course, if the severity filter does not allow this message, then no action is taken.
    ///
    /// - Note: The channel might choose to hold this log message in a buffer, for instance while it waits for a log file to be created, or a network call to complete.
    ///
    /// - Parameter message: The message to append to this channel
    func append(_ message: LogMessageProtocol) {
        
        guard severityFilter.allows(message) else {
            return
        }
        
        do {
            try location.append(message, options: options)
        }
        catch {
            print("""
            FAILED TO APPEND LOG MESSAGE TO CHANNEL "\(name)" - \(error.localizedDescription):
            \(message.entireRenderedLogLine(options: .init(severityStyle: logSeverityNameStyle)))
            """)
        }
    }
    
    
    /// Appends the given log message to this channel if the severity filter allows.
    ///
    /// Of course, if the severity filter does not allow this message, then no action is taken.
    ///
    /// - Note: The channel might choose to hold this log message in a buffer, for instance while it waits for a log file to be created, or a network call to complete.
    ///
    /// - Parameter message: The message to append to this channel
    func append(_ message: LogMessageProtocol)
    where Location: LogChannelLocation
    {
        guard severityFilter.allows(message) else {
            return
        }
        
        location.append(message, options: options)
    }
}
