//
//  Simple Logging.swift
//  
//
//  Created by Ben Leggiero on 2020-05-18.
//

import Foundation



/// The core log function, which pushes the given message to the given channels
///
/// - Parameters:
///   - message:  The message to log to the given channels
///   - channels: _optional_ - The channels to which to push the given message. Defaults to `LogManager.defaultChannels`
///
/// - Returns: _optional_ - The message which was logged
@discardableResult
public func log(message: LogMessageProtocol, to channels: [LogChannel] = LogManager.defaultChannels) -> LogMessageProtocol {
    
    for channel in channels {
        do {
            try channel.append(message)
        }
        catch {
            print("""
            FAILED TO APPEND LOG MESSAGE TO CHANNEL "\(channel.name)" - \(error.localizedDescription):
            \(message.entireRenderedLogLine(options: .init(severityStyle: channel.logSeverityNameStyle)))
            """)
        }
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
                to channels: [LogChannel] = LogManager.defaultChannels
) -> LogMessageProtocol {
    log(
        message: CodeLogMessage(
            severity: severity,
            logLine: loggable.logStringValue,
            codeLocation: CodeLocation(
                filePath: file,
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
                to channels: [LogChannel] = LogManager.defaultChannels
) -> LogMessageProtocol {
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
                to channels: [LogChannel] = LogManager.defaultChannels
) -> LogMessageProtocol {
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
                to channels: [LogChannel] = LogManager.defaultChannels
) -> LogMessageProtocol {
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
                to channels: [LogChannel] = LogManager.defaultChannels
) -> LogMessageProtocol {
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
                to channels: [LogChannel] = LogManager.defaultChannels
) -> LogMessageProtocol {
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
                to channels: [LogChannel] = LogManager.defaultChannels
) -> LogMessageProtocol {
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
                to channels: [LogChannel] = LogManager.defaultChannels
) -> LogMessageProtocol {
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
                to channels: [LogChannel] = LogManager.defaultChannels
) -> LogMessageProtocol {
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
                to channels: [LogChannel] = LogManager.defaultChannels
) -> LogMessageProtocol {
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
                to channels: [LogChannel] = LogManager.defaultChannels
) -> LogMessageProtocol {
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
                to channels: [LogChannel] = LogManager.defaultChannels
) -> LogMessageProtocol {
    log(severity: .error, any,
        file: file, function: function, line: line,
        to: channels)
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
                to channels: [LogChannel] = LogManager.defaultChannels
) -> LogMessageProtocol {
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
                to channels: [LogChannel] = LogManager.defaultChannels
) -> LogMessageProtocol {
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
                     to channels: [LogChannel] = LogManager.defaultChannels
) -> LogMessageProtocol {
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
public func logEdit(file: String = #file, function: String = #function, line: UInt = #line,
                    to channels: [LogChannel] = LogManager.defaultChannels
) -> LogMessageProtocol {
    log(verbose: "Exit",
        file: file, function: function, line: line,
        to: channels)
}
