//
//  LogSeverity.swift
//  SimpleLogging
//
//  Created by Ky Leggiero on 2020-05-18.
//

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import CoreGraphics.CGBase
#endif



/// How severe a log message is
public struct LogSeverity {
    
    /// Allows two severities to be compared
    internal let severityValue: CGFloat
    
    /// The name for this severity
    ///
    /// - `short`: The one-character name to print in truncated logs
    /// - `long`:  The full human-readable name, to print in long-form logs or when listing severities
    /// - `emoji`: The emoji name, for when colored output in plaintext is desired
    @usableFromInline
    internal let name: Name
    
    
    public init(severityValue: CGFloat, name: Name) {
        self.severityValue = severityValue
        self.name = name
    }
    
    
    
    /// The name for a severity
    ///
    /// - `short`: The one-character name to print in truncated logs
    /// - `long`:  The full human-readable name, to print in long-form logs or when listing severities
    /// - `emoji`: The emoji name, for when colored output in plaintext is desired
    public typealias Name = (short: Character, long: String, emoji: Character)
}



// MARK: - Comparable

extension LogSeverity: Comparable {
    
    public static func < (lhs: LogSeverity, rhs: LogSeverity) -> Bool {
        lhs.severityValue < rhs.severityValue
    }
    
    
    public static func == (lhs: LogSeverity, rhs: LogSeverity) -> Bool {
        lhs.severityValue == rhs.severityValue
    }
}



// MARK: - Built-in severities

public extension LogSeverity {
    
    /// Verbose logging - The lowest severity; anything and everything might be logged at this level
    static let verbose = LogSeverity(severityValue: 1,    name: (short: "v", long: "Verbose", emoji: "💬"))
    
    /// Debug logging - Usually not included in user logs, but helpful messages for debugging issues in the field
    static let debug =   LogSeverity(severityValue: 2,    name: (short: "d", long: "Debug",   emoji: "👩🏾‍💻"))
    
    /// Info logging - Usually the lowest level that appears in user logs, information for power-users who look at logs
    static let info =    LogSeverity(severityValue: 3,    name: (short: "i", long: "Info",    emoji: "ℹ️"))
    
    /// Warning logging - Describing potential future problems. Future might be the next line, the next release, etc.
    static let warning = LogSeverity(severityValue: 4,    name: (short: "w", long: "Warning", emoji: "⚠️"))
    
    /// Error logging - Problems that just happened. A server log might only print lines of this severity or higher.
    static let error =   LogSeverity(severityValue: 5,    name: (short: "e", long: "Error",   emoji: "🆘"))
    
    /// Fatal logging - The only fatal lines in a log file should be the last lines, in the event of a crash
    static let fatal =   LogSeverity(severityValue: 1000, name: (short: "f", long: "Fatal",   emoji: "🚨"))
}


// MARK: Alternative semantics

public extension LogSeverity {
    
    /// The default log severity when logging. If you don't care about the severity, it's safe to use this one.
    @inline(__always)
    static var defaultOut: LogSeverity { verbose }
    
    /// The default log severity when filtering a log. If you don't care about the severity, it's safe to use this one.
    @inline(__always)
    static var defaultFilter: LogSeverity { info }
    
    /// Trace logging - When you're trying to trace a code path. Usually scope entry and exit lines use this
    @inline(__always)
    static var trace: LogSeverity { verbose }
    
    /// Critical logging - Anything that's very important to go into the log, but does not indicate a crash
    @inline(__always)
    static var critical: LogSeverity { error }
}


// MARK: Alternative spellings

public extension LogSeverity {
    
    /// An **alias** for "info", when you want your log severity names to be 5 characters. **This has no effect on the log output.**
    @inline(__always)
    static var inform: LogSeverity { info }
    
    /// An **alias** for "info", when you want your log severity names to be full words. **This has no effect on the log output.**
    @inline(__always)
    static var information: LogSeverity { info }
    
    /// An **alias** for "info", when you want your log severity names to be full words. **This has no effect on the log output.**
    @inline(__always)
    static var informative: LogSeverity { info }
    
    
    /// An **alias** for "warning", when you want your log severity names to be 4 characters. **This has no effect on the log output.**
    @inline(__always)
    static var warn: LogSeverity { warning }
}



// MARK: - Name selection

/// A style of the severity part of a log line
public enum SeverityNameStyle {
    
    /// The short name (just 1 character). Good for when ASCII-only is required
    case shortName
    
    /// The unpadded full name. Note that this will leave a jagged edge in any log with more than 1 severity
    case unpaddedFullName
    
    /// The emoji name (just 1 emoji character). Good for helping humans skim a log
    case emoji
    
    
    /// The style that's used by default, if none is specified.
    ///
    /// Currently set to `.emoji`, so people can more easily skim the log
    public static var `default`: Self { emoji }
}



public extension LogSeverity {
    
    /// Returns the text name of this severity in the given style
    ///
    /// - Parameter style: The style of name to return
    /// - Returns: The text name of this severity in the given style
    @inlinable
    func name(style: SeverityNameStyle) -> String {
        switch style {
        case .shortName:        return name.short.description
        case .unpaddedFullName: return name.long.description
        case .emoji:            return name.emoji.description
        }
    }
}
