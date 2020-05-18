//
//  CodeLogMessage.swift
//  
//
//  Created by Ben Leggiero on 2020-05-18.
//

import Foundation



/// A log message in and about the code. This is most log lines.
public struct CodeLogMessage: LogMessageProtocol {
    public let dateLogged: Date
    public let severity: LogSeverity
    public let logLine: String
    
    /// The location of the log line within the code
    public let codeLocation: CodeLocation
    
    
    public init(
        dateLogged: Date = Date(),
        severity: LogSeverity,
        logLine: String,
        codeLocation: CodeLocation
    ) {
        self.dateLogged = dateLogged
        self.severity = severity
        self.logLine = logLine
        self.codeLocation = codeLocation
    }
}



public extension CodeLogMessage {
    init(severity: LogSeverity,
         logLine: String,
         locationFilePath: String = #file,
         locationFunctionIdentifier: String = #function,
         locationLineNumber: UInt = #line
    ) {
        self.init(
            dateLogged: Date(),
            severity: severity,
            logLine: logLine,
            codeLocation: CodeLocation(filePath: locationFilePath,
                                       functionIdentifier: locationFunctionIdentifier,
                                       lineNumber: locationLineNumber))
    }
}



/// A location within code
public struct CodeLocation {
    
    /// The file in which there is code
    public let filePath: String
    
    /// The function in which the code line resides, for future reference
    public let functionIdentifier: String
    
    /// The line number of the code in question
    public let lineNumber: UInt
    
    
    public init(
        filePath: String,
        functionIdentifier: String,
        lineNumber: UInt
    ) {
        self.filePath = filePath
        self.functionIdentifier = functionIdentifier
        self.lineNumber = lineNumber
    }
}
