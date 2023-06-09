//
//  LogChannelLocation + Swift.print.swift
//  SimpleLogging
//
//  Created by Ben Leggiero on 2021-05-30.
//  Copyright © 2021 Ben Leggiero BH-1-PS
//

import Foundation



/// The default place to which Swift's `print` function is directed
public struct SwiftPrintDefaultLogChannelLocation: SingletonLogChannelLocation {
    
    public func append(_ message: LogMessageProtocol, options: LoggingOptions) {
        print(message.entireRenderedLogLine(options: options))
    }
    
    
    
    /// The shared implementation of a `SwiftPrintDefaultLogChannelLocation`
    public static let shared = Self()
}



public extension UnreliableLogChannelLocation where Self == SwiftPrintDefaultLogChannelLocation {
    
    /// The default place to which Swift's `print` function is directed
    static var swiftPrint: Self { .shared }
}



public extension LogChannel
where Location == SwiftPrintDefaultLogChannelLocation {
    
    /// The log channel location which logs to the default place to which Swift's `print` function is directed
    static func swiftPrintDefault(
        name: String = "Swift.print",
        lowestAllowedSeverity: LogSeverity,
        logSeverityNameStyle: SeverityNameStyle = .default)
    -> Self {
        Self.init(name: name, lowestAllowedSeverity: lowestAllowedSeverity, logSeverityNameStyle: logSeverityNameStyle)
    }
    
    
    /// The log channel location which logs to the default place to which Swift's `print` function is directed
    static func swiftPrintDefault(
        name: String = "Swift.print",
        severityFilter: LogSeverityFilter = .default,
        logSeverityNameStyle: SeverityNameStyle = .default)
    -> Self {
        Self.init(name: name, severityFilter: severityFilter, logSeverityNameStyle: logSeverityNameStyle)
    }
}
