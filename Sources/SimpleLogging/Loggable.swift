//
//  Loggable.swift
//  
//
//  Created by Ben Leggiero on 2020-05-18.
//

import Foundation
import CoreGraphics.CGBase



/// Something which can be logged, like a `String`
public protocol Loggable {
    /// The text to place in a log line.
    /// This **shouldn't** include metadata like the timestamp, line number, nor severity.
    var logStringValue: String { get }
}



// MARK: - Default conformances

extension Loggable where Self: CustomStringConvertible {
    @inlinable
    public var logStringValue: String { description }
}



extension String: Loggable {
    @inline(__always)
    public var logStringValue: String { self }
}



extension Int: Loggable {}
extension Int8: Loggable {}
extension Int16: Loggable {}
extension Int32: Loggable {}
extension Int64: Loggable {}

extension UInt: Loggable {}
extension UInt8: Loggable {}
extension UInt16: Loggable {}
extension UInt32: Loggable {}
extension UInt64: Loggable {}


extension Float32: Loggable {}
extension Float64: Loggable {}
extension CGFloat: Loggable {}
