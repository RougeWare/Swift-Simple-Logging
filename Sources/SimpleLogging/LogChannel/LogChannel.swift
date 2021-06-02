//
//  LogChannel.swift
//  SimpleLogging
//
//  Created by Ben Leggiero on 2020-05-18.
//  Copyright © 2020 Ben Leggiero BH-1-PS
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
    public let logSeverityNameStyle: SeverityNameStyle
    
    
    /// The logging options to use with each message
    private let options: LoggingOptions
    
    
    // MARK: Init
    
    /// Creates a new log channel with the given configuration. You usually don't need to use this; instead you can use the static functions like `.file` or `.swiftPrintDefault`.
    ///
    /// - Parameters:
    ///   - name:                  The human-readable name of the channel
    ///   - location:              The location where the logs are channeled to
    ///   - severityFilter:        _optional_ - The filter which decides which messages appear in this channel's logs. Defaults to allowing `info` and higher, since `info` is the lowest built-in severity which users might care about if they're looking at logs, but not debugging the code itself.
    ///   - logSeverityNameStyle:  _optional_ - The style of the severity names that appear in the log. Defaults to `.default`.
    ///
    /// - Throws: Any error which occurs while trying to create the channel
    public init(
        name: String,
        location: Location,
        severityFilter: LogSeverityFilter = .default,
        logSeverityNameStyle: SeverityNameStyle = .default)
    {
        self.name = name
        self.location = location
        self.severityFilter = severityFilter
        self.logSeverityNameStyle = logSeverityNameStyle
        self.options = LoggingOptions(severityStyle: logSeverityNameStyle)
    }
    
    
    /// Creates a new log channel with the given configuration. You usually don't need to use this; instead you can use the static functions like `.file` or `.swiftPrintDefault`.
    ///
    /// - Parameters:
    ///   - name:                  The human-readable name of this channel
    ///   - location:              The location to which this channel sends its log messages
    ///   - lowestAllowedSeverity: _optional_ - The lowest severity which will appear in this channel's logs. Defaults to `defaultFilter`, since that's the lowest built-in severity which users might care about if they're looking at logs, but not debugging the code itself.
    ///   - logSeverityNameStyle:  _optional_ - The style of the severity names that appear in the log. Defaults to `.default`.
    ///
    /// - Throws: Any error which occurs while trying to create the channel
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



public extension LogChannel {
    
    /// Appends the given log message to this channel. If that can't be done, (for example, if the channel's location
    /// is a file on a read-only volume) a semantic error is thrown.
    ///
    /// - Note: The channel might choose to hold this log message in a buffer, for instance while it waits for a log file to be created
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
}



// MARK: - LogSeverityFilter

/// A filter which can be applied to a log channel to specify which messages are allowed through, based on their severities
//@dynamicMemberLookup // Would love this, but doesn't seem it works quite yet
public enum LogSeverityFilter {
    
    /// All messages are allowed
    case allowAll
    
    /// No messages are allowed
    case allowNone
    
    /// Only allow messages of this severity
    case only(LogSeverity)
    
    /// Only allow messages whose severity is in this range of severities
    case range(ClosedRange<LogSeverity>)
    
    /// Allow messages with this severity and higher
    case specificAndHigher(lowest: LogSeverity)
    
    
    
//    static subscript(dynamicMember keyPath: KeyPath<LogSeverity.Type, LogSeverity>) -> LogSeverityFilter {
//        return .specificAndHigher(lowest: LogSeverity.self[keyPath: keyPath])
//    }
    
    
    /// The filter that's used by default, if none is specified
    public static var `default`: Self { specificAndHigher(lowest: .info) }
}



public extension LogSeverityFilter {
    
    /// Whether or not this filter allows the given message to be logged
    ///
    /// - Parameter message: The message which might be allowed through this filter
    /// - Returns: `true` iff the given message is allowed through this filter
    @inline(__always)
    func allows(_ message: LogMessageProtocol) -> Bool {
        allows(message.severity)
    }
    
    
    /// Whether or not this fitler allows messages with the given severity to be logged
    ///
    /// - Parameter severity: A severity to check against this filter
    /// - Returns: `true` iff messages with the given severity are allowed through this filter
    @inlinable
    func allows(_ severity: LogSeverity) -> Bool {
        switch self {
        case .allowAll: return true
        case .allowNone: return false
        
        case .only(severity): return true
        case .only(_): return false
        
        case .range(let range):
            return range.contains(severity)
            
        case .specificAndHigher(lowest: let lowest):
            return lowest <= severity
        }
    }
}
