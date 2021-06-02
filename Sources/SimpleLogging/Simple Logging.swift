//
//  Simple Logging.swift
//  SimpleLogging
//
//  Created by Ben Leggiero on 2020-05-18.
//  Copyright © 2020 Ben Leggiero BH-1-PS
//

import Foundation



public let defaultLoggedErrorAndMessageSeparator = "  \t"



/// The core log function, which pushes the given message to the given channels
///
/// - Parameters:
///   - message:  The message to log to the given channels
///   - channels: _optional_ - The channels to which to push the given message. Defaults to `LogManager.defaultChannels`
///
/// - Returns: _optional_ - The message which was logged
@discardableResult
public func log(message: LogMessageProtocol,
                to channels: [AnyLogChannel] = LogManager.defaultChannels)
-> LogMessageProtocol {
    
    for channel in channels {
        channel.append(message)
    }
    
    return message
}



// MARK: - Conveniences

// MARK: Base log conveniences

/// Logs the given item (and the location where you called this function) at the given severity to the given channels
///
/// - Parameters:
///   - severity: The severity of the message
///   - loggable: The item to be logged
///   - channels: _optional_ - The channels to which to log the given item
///
/// - Returns: The message which was logged
@discardableResult
@inlinable
public func log(severity: LogSeverity, _ loggable: Loggable,
                file: String = #file, function: String = #function, line: UInt = #line,
                to channels: [AnyLogChannel] = LogManager.defaultChannels)
-> LogMessageProtocol {
    log(
        message: CodeLogMessage(
            severity: severity,
            message: loggable.logStringValue,
            codeLocation: CodeLocation(
                fullFilePath: file,
                functionIdentifier: function,
                lineNumber: line
            )
        ),
        to: channels
    )
}


/// Logs the given item (and the location where you called this function) at the given severity to the given channels
///
/// - Parameters:
///   - severity: The severity of the message
///   - loggable: The item to be logged
///   - channels: _optional_ - The channels to which to log the given item
///
/// - Returns: The message which was logged
@discardableResult
@inline(__always)
public func log(severity: LogSeverity, _ any: Any,
                file: String = #file, function: String = #function, line: UInt = #line,
                to channels: [AnyLogChannel] = LogManager.defaultChannels)
-> LogMessageProtocol {
    log(severity: severity, "\(any)" as Loggable,
        file: file, function: function, line: line,
        to: channels)
}


// MARK: Verbose

/// Logs the given item (and the location where you called this function) at `verbose` severity to the given channels
///
/// - Parameters:
///   - loggable: The item to be logged
///   - channels: _optional_ - The channels to which to log the given item
///
/// - Returns: The message which was logged
@discardableResult
@inline(__always)
public func log(verbose loggable: Loggable,
                file: String = #file, function: String = #function, line: UInt = #line,
                to channels: [AnyLogChannel] = LogManager.defaultChannels)
-> LogMessageProtocol {
    log(severity: .verbose, loggable,
        file: file, function: function, line: line,
        to: channels)
}


/// Logs the given item (and the location where you called this function) at `verbose` severity to the given channels
///
/// - Parameters:
///   - any:      The item to be logged
///   - channels: _optional_ - The channels to which to log the given item
///
/// - Returns: The message which was logged
@discardableResult
@inline(__always)
public func log(verbose any: Any,
                file: String = #file, function: String = #function, line: UInt = #line,
                to channels: [AnyLogChannel] = LogManager.defaultChannels)
-> LogMessageProtocol {
    log(severity: .verbose, any,
        file: file, function: function, line: line,
        to: channels)
}


// MARK: Debug

/// Logs the given item (and the location where you called this function) at `debug` severity to the given channels
///
/// - Parameters:
///   - loggable: The item to be logged
///   - channels: _optional_ - The channels to which to log the given item
///
/// - Returns: The message which was logged
@discardableResult
@inline(__always)
public func log(debug loggable: Loggable,
                file: String = #file, function: String = #function, line: UInt = #line,
                to channels: [AnyLogChannel] = LogManager.defaultChannels)
-> LogMessageProtocol {
    log(severity: .debug, loggable,
        file: file, function: function, line: line,
        to: channels)
}


/// Logs the given item (and the location where you called this function) at `debug` severity to the given channels
///
/// - Parameters:
///   - any:      The item to be logged
///   - channels: _optional_ - The channels to which to log the given item
///
/// - Returns: The message which was logged
@discardableResult
@inline(__always)
public func log(debug any: Any,
                file: String = #file, function: String = #function, line: UInt = #line,
                to channels: [AnyLogChannel] = LogManager.defaultChannels)
-> LogMessageProtocol {
    log(severity: .debug, any,
        file: file, function: function, line: line,
        to: channels)
}


// MARK: Info

/// Logs the given item (and the location where you called this function) at `info` severity to the given channels
///
/// - Parameters:
///   - loggable: The item to be logged
///   - channels: _optional_ - The channels to which to log the given item
///
/// - Returns: The message which was logged
@discardableResult
@inline(__always)
public func log(info loggable: Loggable,
                file: String = #file, function: String = #function, line: UInt = #line,
                to channels: [AnyLogChannel] = LogManager.defaultChannels)
-> LogMessageProtocol {
    log(severity: .info, loggable,
        file: file, function: function, line: line,
        to: channels)
}


/// Logs the given item (and the location where you called this function) at `info` severity to the given channels
///
/// - Parameters:
///   - any:      The item to be logged
///   - channels: _optional_ - The channels to which to log the given item
///
/// - Returns: The message which was logged
@discardableResult
@inline(__always)
public func log(info any: Any,
                file: String = #file, function: String = #function, line: UInt = #line,
                to channels: [AnyLogChannel] = LogManager.defaultChannels)
-> LogMessageProtocol {
    log(severity: .info, any,
        file: file, function: function, line: line,
        to: channels)
}


// MARK: Warning

/// Logs the given item (and the location where you called this function) at `warning` severity to the given channels
///
/// - Parameters:
///   - loggable: The item to be logged
///   - channels: _optional_ - The channels to which to log the given item
///
/// - Returns: The message which was logged
@discardableResult
@inline(__always)
public func log(warning loggable: Loggable,
                file: String = #file, function: String = #function, line: UInt = #line,
                to channels: [AnyLogChannel] = LogManager.defaultChannels)
-> LogMessageProtocol {
    log(severity: .warning, loggable,
        file: file, function: function, line: line,
        to: channels)
}


/// Logs the given item (and the location where you called this function) at `warning` severity to the given channels
///
/// - Parameters:
///   - any:      The item to be logged
///   - channels: _optional_ - The channels to which to log the given item
///
/// - Returns: The message which was logged
@discardableResult
@inline(__always)
public func log(warning any: Any,
                file: String = #file, function: String = #function, line: UInt = #line,
                to channels: [AnyLogChannel] = LogManager.defaultChannels)
-> LogMessageProtocol {
    log(severity: .warning, any,
        file: file, function: function, line: line,
        to: channels)
}


// MARK: Error

/// Logs the given item (and the location where you called this function) at `error` severity to the given channels
///
/// - Parameters:
///   - loggable: The item to be logged
///   - channels: _optional_ - The channels to which to log the given item
///
/// - Returns: The message which was logged
@discardableResult
@inline(__always)
public func log(error loggable: Loggable,
                file: String = #file, function: String = #function, line: UInt = #line,
                to channels: [AnyLogChannel] = LogManager.defaultChannels)
-> LogMessageProtocol {
    log(severity: .error, loggable,
        file: file, function: function, line: line,
        to: channels)
}


/// Logs the given item (and the location where you called this function) at `error` severity to the given channels
///
/// - Parameters:
///   - any:      The item to be logged
///   - channels: _optional_ - The channels to which to log the given item
///
/// - Returns: The message which was logged
@discardableResult
@inline(__always)
public func log(error any: Any,
                file: String = #file, function: String = #function, line: UInt = #line,
                to channels: [AnyLogChannel] = LogManager.defaultChannels)
-> LogMessageProtocol {
    log(severity: .error, any,
        file: file, function: function, line: line,
        to: channels)
}


/// Logs the given error (and the location where you called this function) at `error` severity to the given channels
///
/// - Parameters:
///   - error:     The error to be logged
///   - message:   _optional_ - A message to send in the log alongside the error
///   - separator: _optional_ - The separator to place between the error and the custom message, iff a custom message
///                is used. Defaults to `"  \t"`
///   - channels:  _optional_ - The channels to which to log the given item
///
/// - Returns: The message which was logged
@discardableResult
@inlinable
public func log(error: Error,
                _ message: Loggable, separator: String = defaultLoggedErrorAndMessageSeparator,
                to channels: [AnyLogChannel] = LogManager.defaultChannels,
                file: String = #file, function: String = #function, line: UInt = #line)
-> LogMessageProtocol
{
    log(severity: .error, ((error as? LoggableError) ?? (error as Loggable)).combined(with: message, separator: separator),
        file: file, function: function, line: line,
        to: channels)
}


/// Calls the given function and, if it throws an error, logs that error (and the location where you called this
/// function) at `error` severity to the given channels, and the given backup function is called and its value is
/// returned. If the given function does not throw an error, then its result is returned and the backup function is not
/// called.
///
/// - Parameters:
///   - dangerousCall: A function which might throw an error
///   - channels:     _optional_ - The channels to which to log the given item
///
/// - Returns: The return value of either `dangerousCall` if it doesn't throw an error, or of `backup` if it does
@inlinable
public func log<Return>(errorIfThrows dangerousCall: @autoclosure () throws -> Return,
                        backup: @autoclosure () -> Return,
                        to channels: [AnyLogChannel] = LogManager.defaultChannels,
                        file: String = #file, function: String = #function, line: UInt = #line)
-> Return {
    do {
        return try dangerousCall()
    }
    catch {
        log(error: error,
            file: file, function: function, line: line,
            to: channels)
        return backup()
    }
}


// MARK: Fatal

/// Logs the given item (and the location where you called this function) at `fatal` severity to the given channels
///
/// - Parameters:
///   - loggable: The item to be logged
///   - channels: _optional_ - The channels to which to log the given item
///
/// - Returns: The message which was logged
@discardableResult
@inline(__always)
public func log(fatal loggable: Loggable,
                file: String = #file, function: String = #function, line: UInt = #line,
                to channels: [AnyLogChannel] = LogManager.defaultChannels)
-> LogMessageProtocol {
    log(severity: .fatal, loggable,
        file: file, function: function, line: line,
        to: channels)
}


/// Logs the given item (and the location where you called this function) at `fatal` severity to the given channels
///
/// - Parameters:
///   - any:      The item to be logged
///   - channels: _optional_ - The channels to which to log the given item
///
/// - Returns: The message which was logged
@discardableResult
@inline(__always)
public func log(fatal any: Any,
                file: String = #file, function: String = #function, line: UInt = #line,
                to channels: [AnyLogChannel] = LogManager.defaultChannels)
-> LogMessageProtocol {
    log(severity: .fatal, any,
        file: file, function: function, line: line,
        to: channels)
}


// MARK: Log entry / exit

/// Logs that the current scope was entered (and the location where you called this function) at `verbose` severity to
/// the given channels.
///
/// For example, you might place this at the start of a notable method:
/// ```
/// func doDangerousStuff() {
///     logEntry(); defer { logExit() }
///     ...
/// }
/// ```
///
///
/// - Parameters:
///   - channels: _optional_ - The channels to which to log the scope entry
///
/// - Returns: The message which was logged
@discardableResult
@inline(__always)
public func logEntry(file: String = #file, function: String = #function, line: UInt = #line,
                     to channels: [AnyLogChannel] = LogManager.defaultChannels)
-> LogMessageProtocol {
    log(verbose: "Entry",
        file: file, function: function, line: line,
        to: channels)
}


/// Logs that the current scope was exited (and the location where you called this function) at `verbose` severity to
/// the given channels.
///
/// For example, you might place this at the start of a notable method:
/// ```
/// func doDangerousStuff() {
///     logEntry(); defer { logExit() }
///     ...
/// }
/// ```
///
///
/// - Parameters:
///   - channels: _optional_ - The channels to which to log the scope entry
///
/// - Returns: The message which was logged
@discardableResult
@inline(__always)
public func logExit(file: String = #file, function: String = #function, line: UInt = #line,
                    to channels: [AnyLogChannel] = LogManager.defaultChannels)
-> LogMessageProtocol {
    log(verbose: "Exit",
        file: file, function: function, line: line,
        to: channels)
}
