//
//  CodeLogMessage.swift
//  SimpleLogging
//
//  Created by Ben Leggiero on 2020-05-18.
//  Copyright © 2020 Ben Leggiero BH-1-PS
//

import Foundation



/// A log message in and about the code. This is most log lines.
public struct CodeLogMessage {
    public let dateLogged: Date
    public let severity: LogSeverity
    public let message: String
    
    /// The location of the log line within the code
    public let codeLocation: CodeLocation
    
    
    public init(
        dateLogged: Date = Date(),
        severity: LogSeverity,
        message: String,
        codeLocation: CodeLocation
    ) {
        self.dateLogged = dateLogged
        self.severity = severity
        self.message = message
        self.codeLocation = codeLocation
    }
}



public extension CodeLogMessage {
    init(severity: LogSeverity,
         message: String,
         locationFullFilePath: String = #file,
         locationFunctionIdentifier: String = #function,
         locationLineNumber: UInt = #line
    ) {
        self.init(
            dateLogged: Date(),
            severity: severity,
            message: message,
            codeLocation: CodeLocation(fullFilePath: locationFullFilePath,
                                       functionIdentifier: locationFunctionIdentifier,
                                       lineNumber: locationLineNumber))
    }
}



extension CodeLogMessage: LogMessageProtocol {
    
    public var logLine: String {
        "\(codeLocation) \t\(message)"
    }
}



/// A location within code
public struct CodeLocation {
    
    /// The file in which there is code
    public let fileName: String
    
    /// The function in which the code line resides, for future reference
    public let functionIdentifier: String
    
    /// The line number of the code in question
    public let lineNumber: UInt
    
    
    public init(
        fullFilePath: String,
        functionIdentifier: String,
        lineNumber: UInt
    ) {
        self.fileName = URL(fileURLWithPath: fullFilePath).lastPathComponent
        self.functionIdentifier = functionIdentifier
        self.lineNumber = lineNumber
    }
}



extension CodeLocation: CustomStringConvertible {
    public var description: String {
        "\(fileName):\(lineNumber) \(functionIdentifier)"
    }
}
