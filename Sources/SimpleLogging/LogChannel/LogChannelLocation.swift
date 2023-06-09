//
//  LogChannelLocation.swift
//  SimpleLogging
//
//  Created by Ben Leggiero on 2021-05-18.
//  Copyright © 2021 Ben Leggiero BH-1-PS
//

import Foundation
import FunctionTools



// MARK: - Common

/// A log channel location respresents a target for a log line within a log channel.
public protocol LogChannelLocation: UnreliableLogChannelLocation {
    
    /// Logs this message to a channel
    ///
    /// - Note: This function shouldn't perform any filtering; the log message has already been filtered by the log channel filter before being passed to this function.
    ///
    /// - Parameters:
    ///   - message: The message to send to the log channel
    ///   - options: Options about how to render the log message
    func append(_ message: LogMessageProtocol, options: LoggingOptions)
}



// MARK: - Base (Unreliable)

/// A log channel location respresents a target for a log line within a log channel, where logging might fail
public protocol UnreliableLogChannelLocation {
    
    /// Attempts to log this message to a channel. If that fails, a descriptive error is thrown.
    ///
    /// - Note: This function shouldn't perform any filtering; the log message has already been filtered by the log channel filter before being passed to this function.
    ///
    /// - Parameters:
    ///   - message: The message to send to the log channel
    ///   - options: Options about how to render the log message
    ///
    /// - Throws: If the message could not be logged
    func append(_ message: LogMessageProtocol, options: LoggingOptions) throws
}



// MARK: - Singleton

/// A log channel location respresents a target for a log line within a log channel.
public protocol SingletonLogChannelLocation: UnreliableLogChannelLocation {
    
    /// The instance of this location which is shared amongst all consumers
    static var shared: Self { get }
}


// MARK: LogChannel Conveniences

public extension LogChannel where Location: SingletonLogChannelLocation {
    
    /// Creates a new log channel with the given configuration, logging to the known location's shared singleton instance
    ///
    /// - Parameters:
    ///   - name:                  The human-readable name of the channel
    ///   - severityFilter:        _optional_ - The filter which decides which messages appear in this channel's logs.
    ///                            Defaults to allowing `info` and higher, since `info` is the lowest built-in severity
    ///                            which users might care about if they're looking at logs, but not debugging the code
    ///                            itself.
    ///   - logSeverityNameStyle:  _optional_ - The style of the severity names that appear in the log.
    ///                            Defaults to `.emoji`, so humans can more easily skim the log.
    ///
    /// - Throws: Any error which occurs while trying to create the channel
    init(name: String, lowestAllowedSeverity: LogSeverity, logSeverityNameStyle: SeverityNameStyle) {
        self.init(name: name, location: .shared, lowestAllowedSeverity: lowestAllowedSeverity, logSeverityNameStyle: logSeverityNameStyle)
    }
    
    
    /// Creates a new log channel with the given configuration, logging to the known location's shared singleton instance
    ///
    /// - Parameters:
    ///   - name:                  The human-readable name of the channel
    ///   - severityFilter:        _optional_ - The filter which decides which messages appear in this channel's logs.
    ///                            Defaults to allowing `info` and higher, since `info` is the lowest built-in severity
    ///                            which users might care about if they're looking at logs, but not debugging the code
    ///                            itself.
    ///   - logSeverityNameStyle:  _optional_ - The style of the severity names that appear in the log.
    ///                            Defaults to `.emoji`, so humans can more easily skim the log.
    ///
    /// - Throws: Any error which occurs while trying to create the channel
    init(name: String, severityFilter: LogSeverityFilter, logSeverityNameStyle: SeverityNameStyle) {
        self.init(name: name, location: .shared, severityFilter: severityFilter, logSeverityNameStyle: logSeverityNameStyle)
    }
}
