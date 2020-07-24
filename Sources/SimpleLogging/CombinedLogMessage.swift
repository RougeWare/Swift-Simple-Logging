//
//  CombinedLogMessage.swift
//  SimpleLogging
//
//  Created by Ben Leggiero on 2020-07-22.
//  Copyright © 2020 Ben Leggiero BH-1-PS
//

import Foundation
import LazyContainers



private let logLineInitialValueBeforeLazyInitializerCanBeCreated = """

Async error. Please file a bug report at https://github.com/RougeWare/Swift-Simple-Logging/issues/new/

"""



public class CombinedLogMessage {
    
    @Lazy
    private var first: LogMessageProtocol
    
    @Lazy
    private var second: LogMessageProtocol
    
    public let separator: String
    
    @Lazy
    public private(set) var logLine: String
    
    
    init(first: Lazy<LogMessageProtocol>,
         second: Lazy<LogMessageProtocol>,
         separator: String)
    {
        self._first = first
        self._second = second
        self.separator = separator
        
        self._logLine = Lazy(wrappedValue: logLineInitialValueBeforeLazyInitializerCanBeCreated)
        self._logLine = Lazy {
            self.first.logLine + separator + self.second.logLine
        }
    }
}



extension CombinedLogMessage: LogMessageProtocol {
    public var severity: LogSeverity { max(first.severity, second.severity) }
    public var dateLogged: Date { min(first.dateLogged, second.dateLogged) }
}
