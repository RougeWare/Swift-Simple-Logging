//
//  LogManager.swift
//  SimpleLogging
//
//  Created by Ky Leggiero on 2020-05-18.
//

import Foundation



/// A touchpoint for managing logging
public enum LogManager {
    // Empty on-purpose; all members are static
}



public extension LogManager {
    
    /// The original set of default channels, kept here so we can reset the default channels
    private static let originalDefaultChannels: [AnyLogChannel] = [
        LogChannel.swiftPrintDefault()
    ]
    
    /// The default set of channels for logging. Changing this will redirect logs which don't specify a channel
    static var defaultChannels = originalDefaultChannels
    
    
    /// Resets the default channels back to its original set of channels
    static func resetDefaultChannels() {
        defaultChannels = originalDefaultChannels
    }
}
