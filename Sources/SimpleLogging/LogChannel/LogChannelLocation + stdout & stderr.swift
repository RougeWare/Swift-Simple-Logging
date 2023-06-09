//
//  LogChannelLocation + stdout & stderr.swift
//  SimpleLogging
//
//  Created by Ben Leggiero on 2021-05-30.
//  Copyright © 2021 Ben Leggiero BH-1-PS
//

import Foundation



// MARK: - stdout

/// Sends messages to standard output (`stdout`)
public struct StandardOutLogChannelLocation: SingletonLogChannelLocation {
    
    public func append(_ message: LogMessageProtocol, options: LoggingOptions) {
        print(message.entireRenderedLogLine(options: options), to: &standardOutput)
    }
    
    
    
    /// The shared implementation of a `StandardOutLogChannelLocation`
    public static let shared = Self()
}



// MARK: - stderr

/// Sends messages to standard error (`stderr`)
public struct StandardErrorLogChannelLocation: SingletonLogChannelLocation {
    
    public func append(_ message: LogMessageProtocol, options: LoggingOptions) {
        print(message.entireRenderedLogLine(options: options), to: &standardError)
    }
    
    
    /// The shared implementation of a `StandardErrorLogChannelLocation`
    public static let shared = Self()
}



// MARK: - both

/// Sends messages to standard output (`stdout`) and standard error (`stderr`), simultaneously
public struct StandardOutAndErrorLogChannelLocation: SingletonLogChannelLocation {
    
    public func append(_ message: LogMessageProtocol, options: LoggingOptions) {
        let line = message.entireRenderedLogLine(options: options)
        print(line, to: &standardError)
        print(line, to: &standardOutput)
    }
    
    
    
    /// The shared implementation of a `StandardOutAndErrorLogChannelLocation`
    public static let shared = Self()
}



// MARK: - Convenience statics

public extension UnreliableLogChannelLocation where Self == StandardOutLogChannelLocation {
    
    /// Sends messages to standard output (`stdout`)
    static var stdout: Self { .shared }
}



public extension UnreliableLogChannelLocation where Self == StandardErrorLogChannelLocation {
    
    /// Sends messages to standard error (`stderr`)
    static var stderr: Self { .shared }
}



public extension UnreliableLogChannelLocation where Self == StandardOutAndErrorLogChannelLocation {
    
    /// Sends messages to standard output (`stdout`) and standard error (`stderr`), simultaneously
    static var stdout_stderr: Self { .shared }
}



public extension LogChannel {
    
    // MARK: Severity filter
    
    /// Allows a log channel to send its messages to standard output (`stdout`)
    ///
    /// - Parameters:
    ///   - name:                  _optional_ - The human-readable name of the channel. Defaults to `stdout`
    ///   - severityFilter:        _optional_ - The filter which decides which messages appear in this channel's logs. Defaults to allowing `info` and higher, since `info` is the lowest built-in severity which users might care about if they're looking at logs, but not debugging the code itself.
    ///   - logSeverityNameStyle:  _optional_ - The style of the severity names that appear in the log. Defaults to `.emoji`, so humans can more easily skim the log.
    static func standardOut(name: String = "stdout", severityFilter: LogSeverityFilter = .default, logSeverityNameStyle: SeverityNameStyle = .default) -> Self
    where Location == StandardOutLogChannelLocation {
        Self.init(name: name, severityFilter: severityFilter, logSeverityNameStyle: logSeverityNameStyle)
    }
    
    
    /// Allows a log channel to send its messages to standard error (`stderr`)
    ///
    /// - Parameters:
    ///   - name:                  _optional_ - The human-readable name of the channel. Defaults to `stdout`
    ///   - severityFilter:        _optional_ - The filter which decides which messages appear in this channel's logs. Defaults to allowing `info` and higher, since `info` is the lowest built-in severity which users might care about if they're looking at logs, but not debugging the code itself.
    ///   - logSeverityNameStyle:  _optional_ - The style of the severity names that appear in the log. Defaults to `.emoji`, so humans can more easily skim the log.
    static func standardError(name: String = "stderr", severityFilter: LogSeverityFilter = .default, logSeverityNameStyle: SeverityNameStyle = .default) -> Self
    where Location == StandardErrorLogChannelLocation {
        Self.init(name: name, severityFilter: severityFilter, logSeverityNameStyle: logSeverityNameStyle)
    }
    
    
    /// Allows a log channel to send its messages to standard output (`stdout`) and standard error (`stderr`), simultaneously
    ///
    /// - Parameters:
    ///   - name:                  _optional_ - The human-readable name of the channel. Defaults to `stdout`
    ///   - severityFilter:        _optional_ - The filter which decides which messages appear in this channel's logs. Defaults to allowing `info` and higher, since `info` is the lowest built-in severity which users might care about if they're looking at logs, but not debugging the code itself.
    ///   - logSeverityNameStyle:  _optional_ - The style of the severity names that appear in the log. Defaults to `.emoji`, so humans can more easily skim the log.
    static func standardOutAndError(name: String = "stdout & stderr", severityFilter: LogSeverityFilter = .default, logSeverityNameStyle: SeverityNameStyle = .default) -> Self
    where Location == StandardOutAndErrorLogChannelLocation {
        Self.init(name: name, severityFilter: severityFilter, logSeverityNameStyle: logSeverityNameStyle)
    }
    
    
    // MARK: Lowest-allowed severity
    
    /// Allows a log channel to send its messages to standard output (`stdout`)
    ///
    /// - Parameters:
    ///   - name:                  The human-readable name of this channel
    ///   - lowestAllowedSeverity: _optional_ - The lowest severity which will appear in this channel's logs. Defaults to `.default`, since that's the lowest built-in severity which users might care about if they're looking at logs, but not debugging the code itself.
    ///   - logSeverityNameStyle:  _optional_ - The style of the severity names that appear in the log. Defaults to `.emoji`, so humans can more easily skim the log.
    static func standardOut(name: String = "stdout", lowestAllowedSeverity: LogSeverity, logSeverityNameStyle: SeverityNameStyle = .default) -> Self
    where Location == StandardOutLogChannelLocation {
        Self.init(name: name, lowestAllowedSeverity: lowestAllowedSeverity, logSeverityNameStyle: logSeverityNameStyle)
    }
    
    
    /// Allows a log channel to send its messages to standard error (`stderr`)
    ///
    /// - Parameters:
    ///   - name:                  The human-readable name of this channel
    ///   - lowestAllowedSeverity: _optional_ - The lowest severity which will appear in this channel's logs. Defaults to `.default`, since that's the lowest built-in severity which users might care about if they're looking at logs, but not debugging the code itself.
    ///   - logSeverityNameStyle:  _optional_ - The style of the severity names that appear in the log. Defaults to `.emoji`, so humans can more easily skim the log.   
    static func standardError(name: String = "stderr", lowestAllowedSeverity: LogSeverity, logSeverityNameStyle: SeverityNameStyle = .default) -> Self
    where Location == StandardErrorLogChannelLocation {
        Self.init(name: name, lowestAllowedSeverity: lowestAllowedSeverity, logSeverityNameStyle: logSeverityNameStyle)
    }
    
    
    /// Allows a log channel to send its messages to standard output (`stdout`) and standard error (`stderr`), simultaneously
    ///
    /// - Parameters:
    ///   - name:                  The human-readable name of this channel
    ///   - lowestAllowedSeverity: _optional_ - The lowest severity which will appear in this channel's logs. Defaults to `.default`, since that's the lowest built-in severity which users might care about if they're looking at logs, but not debugging the code itself.
    ///   - logSeverityNameStyle:  _optional_ - The style of the severity names that appear in the log. Defaults to `.emoji`, so humans can more easily skim the log.
    static func standardOutAndError(name: String = "stdout & stderr", lowestAllowedSeverity: LogSeverity, logSeverityNameStyle: SeverityNameStyle = .default) -> Self
    where Location == StandardOutAndErrorLogChannelLocation {
        Self.init(name: name, lowestAllowedSeverity: lowestAllowedSeverity, logSeverityNameStyle: logSeverityNameStyle)
    }
}
