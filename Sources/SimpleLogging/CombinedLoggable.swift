//
//  CombinedLogMessage.swift
//  SimpleLogging
//
//  Created by Ben Leggiero on 2020-07-22.
//  Copyright © 2020 Ben Leggiero BH-1-PS
//

import Foundation
import LazyContainers



public struct CombinedLoggable: Loggable {
    
    @Lazy
    public private(set) var logStringValue: String
    
    
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
