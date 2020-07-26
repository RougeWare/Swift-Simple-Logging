//
//  CombinedLogMessage.swift
//  SimpleLogging
//
//  Created by Ben Leggiero on 2020-07-22.
//  Copyright © 2020 Ben Leggiero BH-1-PS
//

import Foundation
import LazyContainers



/// Two lazily-combined loggables
@usableFromInline
internal struct CombinedLoggable: Loggable {
    
    @Lazy
    public private(set) var logStringValue: String
    
    
    /// Lazily combines these two `Loggable`s into one
    ///
    /// - Parameters:
    ///   - first:     The first `Loggable` to combine. This will always appear before the second.
    ///   - second:    The second `Loggable` to combine. This will always appear after the first.
    ///   - separator: The text which will separate the two messages.
    public init(first: Lazy<Loggable>, second: Lazy<Loggable>, separator: String) {
        self._logStringValue = Lazy(wrappedValue: first.wrappedValue.logStringValue + separator + second.wrappedValue.logStringValue)
    }
}



// MARK: - Sugar

public extension Loggable {
    
    /// Combines this loggable with another
    ///
    /// - Parameters:
    ///   - other:     The other loggable to combine with this one
    ///   - separator: The text to separate them in the log
    ///
    /// - Returns: This loggable combined with the given one
    @inlinable
    func combined(with other: Loggable, separator: String) -> Loggable {
        CombinedLoggable(first: .init(wrappedValue: self),
                         second: .init(wrappedValue: other),
                         separator: separator)
    }
}
