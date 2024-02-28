//
//  LoggableError.swift
//  SimpleLogging
//
//  Created by Ky Leggiero on 2020-08-16.
//

import Foundation



extension NSError: Loggable {}



/// A special kind of error designed to be logged.
///
/// While all errors can be logged, types conforming to this can be inspected to get the best possible text to be
/// logged, and can customize exactly what is logged if desired.
public protocol LoggableError: Loggable, LocalizedError, CustomStringConvertible {
    
    /// The best text to send to a log which describes this error
    var bestDescriptionForLogLine: String { get }
    
    
    /// A textual representation of this error.
    ///
    /// See also: `CustomStringConvertible`'s `description` field
    var description: String { get }
}



public extension LoggableError {
    
    @inline(__always)
    var logStringValue: String { bestDescriptionForLogLine }
    
    
    var bestDescriptionForLogLine: String {
        var descriptionSoFar = ""
        
        if let errorDescription = errorDescription {
            descriptionSoFar += "\(errorDescription)"
        }
        if let recoverySuggestion = self.recoverySuggestion {
            descriptionSoFar += "\t-\t\(recoverySuggestion)"
        }
        
        return descriptionSoFar.isEmpty
            ? description
            : descriptionSoFar
    }
}
