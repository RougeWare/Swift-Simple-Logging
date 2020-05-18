//
//  LogMessage.swift
//  
//
//  Created by Ben Leggiero on 2020-05-18.
//

import Foundation



/// The default Loggable, and the return value of a log call
public struct LogMessage: LogMessageProtocol {
    public let dateLogged: Date
    public let severity: LogSeverity
    public let logLine: String
    
    
    init(dateLogged: Date = Date(),
         severity: LogSeverity,
         logLine: String
    ) {
        self.dateLogged = dateLogged
        self.severity = severity
        self.logLine = logLine
    }
}



extension LogMessage: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(severity: .default, logLine: value)
    }
}
