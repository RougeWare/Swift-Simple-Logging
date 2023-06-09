//
//  LogSeverityFilter.swift
//  
//
//  Created by Ky Leggiero on 2023-06-08.
//

import Foundation



/// A filter which can be applied to a log channel to specify which messages are allowed through, based on their severities
//@dynamicMemberLookup // Would love this, but doesn't seem it works quite yet
public enum LogSeverityFilter {
    
    /// All messages are allowed
    case allowAll
    
    /// No messages are allowed
    case allowNone
    
    /// Only allow messages of this severity
    case only(LogSeverity)
    
    /// Only allow messages whose severity is in this range of severities
    case range(ClosedRange<LogSeverity>)
    
    /// Allow messages with this severity and higher
    case specificAndHigher(lowest: LogSeverity)
    
    
    
//    static subscript(dynamicMember keyPath: KeyPath<LogSeverity.Type, LogSeverity>) -> LogSeverityFilter {
//        return .specificAndHigher(lowest: LogSeverity.self[keyPath: keyPath])
//    }
    
    
    /// The filter that's used by default, if none is specified.
    ///
    /// Use this if you don't care about which exact filter behavior is used, and just want a good default behavior.
    ///
    /// Currently, this allows messages at a severity which users might care about if they're looking at logs, but not debugging the code itself.
    /// That implementation and philosophy might change; don't depend on default behavior if you truly need specific behavior
    public static var `default`: Self { specificAndHigher(lowest: .info) }
}



public extension LogSeverityFilter {
    
    /// Whether or not this filter allows the given message to be logged
    ///
    /// - Parameter message: The message which might be allowed through this filter
    /// - Returns: `true` iff the given message is allowed through this filter
    @inline(__always)
    func allows(_ message: LogMessageProtocol) -> Bool {
        allows(message.severity)
    }
    
    
    /// Whether or not this filter allows messages with the given severity to be logged
    ///
    /// - Parameter severity: A severity to check against this filter
    /// - Returns: `true` iff messages with the given severity are allowed through this filter
    @inlinable
    func allows(_ severity: LogSeverity) -> Bool {
        switch self {
        case .allowAll: return true
        case .allowNone: return false
        
        case .only(severity): return true
        case .only(_): return false
        
        case .range(let range):
            return range.contains(severity)
            
        case .specificAndHigher(lowest: let lowest):
            return lowest <= severity
        }
    }
}
