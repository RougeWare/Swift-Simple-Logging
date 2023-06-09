//
//  CombinedLogMessage.swift
//  SimpleLogging
//
//  Created by Ky Leggiero on 2020-07-22.
//

import Foundation
import LazyContainers



// Swift made me do this :c
/// The message printed if something tries to log this message before it's done initializing
private let logLineInitialValueBeforeLazyInitializerCanBeCreated = Lazy(wrappedValue: """

Async error. Please file a bug report at https://github.com/RougeWare/Swift-Simple-Logging/issues/new/

""")



/// Two log messages, lazily combined
internal class CombinedLogMessage {
    
    /// The first message to combine. This will always be printed before the second message.
    @Lazy
    private var first: LogMessageProtocol
    
    /// The second message to combine. This will always be printed after the first message.
    @Lazy
    private var second: LogMessageProtocol
    
    /// The text which will separate the two messages in the log
    public let separator: String
    
    /// Both messages, finally combined
    @Lazy
    public private(set) var logLine: String
    
    
    /// Lazily combines the given log messages
    ///
    /// - Parameters:
    ///   - first:     The first message to combine. This will always be printed before the second message
    ///   - second:    The second message to combine. This will always be printed after the first message.
    ///   - separator: The text which will separate the two messages in the log
    init(first: Lazy<LogMessageProtocol>,
         second: Lazy<LogMessageProtocol>,
         separator: String)
    {
        self._first = first
        self._second = second
        self.separator = separator
        
        self._logLine = logLineInitialValueBeforeLazyInitializerCanBeCreated
        self._logLine = Lazy {
            self.first.logLine + separator + self.second.logLine
        }
    }
}



extension CombinedLogMessage: LogMessageProtocol {
    
    /// The higher of the two severities
    @inline(__always)
    public var severity: LogSeverity { max(first.severity, second.severity) }
    
    
    /// The older of the two dates these were logged
    @inline(__always)
    public var dateLogged: Date { min(first.dateLogged, second.dateLogged) }
}
