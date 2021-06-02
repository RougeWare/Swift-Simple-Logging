//
//  LogChannel + PII.swift
//  SimpleLogging
//
//  Created by Ben Leggiero on 2021-05-18.
//  Copyright © 2021 Ben Leggiero BH-1-PS
//

import Foundation



public extension LogChannel where Location == SwiftPrintDefaultLogChannelLocation {
    
    /// A log channel which allows you to safely print log lines which contain personally-identifiable information.
    ///
    /// Generally, this attempts to be a channel which only ever presents PII to developers testing locally, never in a place where a real-world individual might have their PII recorded inadvertently.
    /// In this way, this channel is also HIPAA-compliant.
    ///
    /// Specifically, this is implemented by only sending messages to the Swift `print` console, and only in `DEBUG` builds.
    /// If you find that this still allows real-world users' PII to be recorded inadvertently, please file a bug report here as soon as possible:
    /// https://github.com/RougeWare/Swift-Simple-Logging/issues/new
    static let pii = Self.swiftPrintDefault(name: "PII",
                                            severityFilter: .pii)
}



private extension LogSeverityFilter {
    
    #if DEBUG
    /// The filter which is appropriate to use for logging personally-identifiable information
    @inline(__always)
    static var pii: Self { .allowAll }
    #else
    /// The filter which is appropriate to use for logging personally-identifiable information
    @inline(__always)
    static var pii: Self { .allowNone }
    #endif
}
