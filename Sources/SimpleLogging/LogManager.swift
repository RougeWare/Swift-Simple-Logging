//
//  File.swift
//  
//
//  Created by Ben Leggiero on 2020-05-18.
//

import Foundation



/// A touchpoint for managing logging
public enum LogManager {
    // Empty on-purpose; all members are static
}



public extension LogManager {
    static var defaultChannels: [LogChannel] = [LogChannel(name: "Swift.print", location: .swiftPrintDefault)]
}
