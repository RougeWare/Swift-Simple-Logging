//
//  LogChannel.swift
//  
//
//  Created by Ben Leggiero on 2020-05-18.
//

import Foundation



/// The channel to which to send log messages
public class LogChannel {
    
    /// The human-readable name of the log channel
    public let name: String
    
    /// The location of the log channel, to which log messages will be sent
    public let location: Location
    
    /// The lowest severity which will be pushed to this channel. All others will be discarded entirely.
    public var lowestAllowedSeverity: LogSeverity?
    
    /// The style of the severity part of a log line in this channel
    public let logSeverityNameStyle: SeverityNameStyle
    
    /// The logging options to use with each message
    private let options: LoggingOptions
    
    /// A handle to a file to which we might append a log message
    private var fileHandle: FileHandle!
    
    
    public init(name: String,
         location: Location,
         lowestAllowedSeverity: LogSeverity? = .info,
         logSeverityNameStyle: SeverityNameStyle = .emoji
    )
        throws
    {
        self.name = name
        self.location = location
        self.lowestAllowedSeverity = lowestAllowedSeverity
        self.logSeverityNameStyle = logSeverityNameStyle
        self.options = LoggingOptions(severityStyle: logSeverityNameStyle)
        
        switch location {
        case .swiftPrintDefault,
            .standardOut,
            .standardError,
            .standardOutAndError:
            break
            
        case .file(path: let path):
            let pathUrl = URL(fileURLWithPath: path)
            let parentDirectory = pathUrl.deletingLastPathComponent()
            
            do {
                try FileManager.default.createDirectory(at: parentDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                print(error)
                assertionFailure("Could not create file parent directory: " + error.localizedDescription)
                throw error
            }
            
            guard FileManager.default.createFile(atPath: path, contents: nil, attributes: nil) else {
                assertionFailure("Could not create file")
                throw LogChannel.CreateError.couldNotCreateLogFile(path: path)
            }
            
            do {
                self.fileHandle = try FileHandle(forWritingTo: pathUrl)
            }
            catch {
                assertionFailure("Could not create file handle pointing to \(path): " + error.localizedDescription)
                throw error
            }
        }
    }
    
    
    deinit {
        fileHandle?.closeFile()
        
        if #available(macOS 15, iOS 13, tvOS 13, watchOS 6, *) {
            try? fileHandle?.close()
        }
    }
}



public extension LogChannel {
    /// The location of a log channel, to which log messages will be sent
    enum Location {
        /// The default place to which Swift's `print` function is directed
        case swiftPrintDefault
        
        
        /// Standard output (`stdout`)
        case standardOut
        
        /// Standard error (`stderr`)
        case standardError
        
        /// Standard output (`stdout`) and standard error (`stderr`), simultaneously
        case standardOutAndError
        
        
        /// A text file - new log lines will be appended
        ///
        /// - Parameter path: The path of the text file which will receive log messages
        case file(path: String)
    }
}



public extension LogChannel {
    
    /// Appends the given log message to this channel. If that can't be done, (for example, if the channel's location
    /// is a file on a read-only volume) a semantic error is thrown.
    ///
    /// - Note: The channel might choose to hold this log message in a buffer, for instance while it waits for a log file to be created
    ///
    /// - Parameter message: The message to append to this channel
    /// - Throws: a semantic error if the message can't be logged (for example, if the channel's location is a file on
    ///           a read-only volume)
    func append(_ message: LogMessageProtocol) throws {
        
        if let lowestAllowedSeverity = lowestAllowedSeverity,
            message.severity < lowestAllowedSeverity
        {
            return
        }
        
        switch location {
        case .swiftPrintDefault:    append_swiftPrintDefault(message)
        case .standardOut:          append_standardOut(message)
        case .standardError:        append_standardError(message)
        case .standardOutAndError:  append_standardOutAndError(message)
        case .file(path: let path): append_file(path: path, message: message)
        }
    }
    
    
    private func append_swiftPrintDefault(_ message: LogMessageProtocol) {
        print(message.entireRenderedLogLine(options: options))
    }
    
    
    private func append_standardOut(_ message: LogMessageProtocol) {
        print(message.entireRenderedLogLine(options: options), to: &standardOutput)
    }
    
    
    private func append_standardError(_ message: LogMessageProtocol) {
        print(message.entireRenderedLogLine(options: options), to: &standardError)
    }
    
    
    @inline(__always)
    private func append_standardOutAndError(_ message: LogMessageProtocol) {
        append_standardOut(message)
        append_standardError(message)
    }
    
    
    private func append_file(path: String, message: LogMessageProtocol) {
        print(message.entireRenderedLogLine(options: options), to: &fileHandle)
    }
}



public extension LogChannel {
    /// An error which might occur while attempting to create a log channel
    enum CreateError: Error {
        /// Thrown when you want to log to a file, but that file could not be created
        case couldNotCreateLogFile(path: String)
    }
}
