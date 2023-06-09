//
//  RawLogMessage.swift
//  SimpleLogging
//
//  Created by Ky Leggiero on 2020-05-18.
//

import Foundation



/// The implementation of `LogMessageProtocol` which is used both for `LogLocation.customRaw`, and internally to track log messages as they flow through the process of being logged
public struct RawLogMessage {
    
    /// The moment at which log function was called
    public let dateLogged: Date
    
    /// The severity of the log message
    public let severity: LogSeverity
    
    /// The location of the log line within the code
    public let codeLocation: CodeLocation
    
    /// The primary message which was logged
    public let message: String
    
    /// Any additinal parameters for this message.
    ///
    /// This is intended to offer superfine customizability to custom log solutions. This will not be used as a placeholder for future fields and must not be treated as such
    public let additionalParameters: [String : Any]?
    
    
    public init(
        dateLogged: Date = Date(),
        severity: LogSeverity,
        codeLocation: CodeLocation,
        message: String,
        additionalParameters: [String : Any]? = nil
    ) {
        self.dateLogged = dateLogged
        self.severity = severity
        self.message = message
        self.codeLocation = codeLocation
        self.additionalParameters = additionalParameters
    }
}



public extension RawLogMessage {
    init(dateLogged: Date = Date(),
         severity: LogSeverity,
         locationFullFilePath: String = #file,
         locationFunctionIdentifier: String = #function,
         locationLineNumber: UInt = #line,
         message: String,
         additionalParameters: [String : Any]? = nil
    ) {
        self.init(
            dateLogged: dateLogged,
            severity: severity,
            codeLocation: CodeLocation(fullFilePath: locationFullFilePath,
                                       functionIdentifier: locationFunctionIdentifier,
                                       lineNumber: locationLineNumber),
            message: message,
            additionalParameters: additionalParameters
        )
    }
}



extension RawLogMessage: LogMessageProtocol {
    
    /// The code location and the message, separated by whitespace
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
