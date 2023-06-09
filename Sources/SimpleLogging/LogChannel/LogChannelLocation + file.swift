//
//  LogChannelLocation + stdout & stderr.swift
//  SimpleLogging
//
//  Created by Ben Leggiero on 2021-05-30.
//  Copyright © 2021 Ben Leggiero BH-1-PS
//

import Foundation



/// Directs log messages to a text file – new log lines will be appended
///
/// - Parameter path: The path of the text file which will receive log messages
public class FileLogChannelLocation: LogChannelLocation {
    
    /// A handle to a file to which we might append a log message
    private var fileHandle: FileHandle
    
    
    /// Creates a new file log channel using the file at the given path
    ///
    /// - Parameters:
    ///   - filePath: The path to the file which will accept the logging
    ///   - createIntermediatesIfNecessary: _optional_ - If the parent directory, or any of its ancestor directories, doesn't exist, then passing `true` will cause this to attempt to create it, whereas if you pass `false`, then this will throw an error if they don't exist. Defaults to `true`.
    ///   - fileManager: _optional_ - The file manager to use when performing file system operations. Defaults to `.default`.
    ///
    /// - Throws: If the parent directory cannot be created, or if you specified that it shouldn't be but it doesn't exist, or if the log file cannot ce created, or if the file couldn't be opened for writing
    public convenience init(filePath: String, createIntermediatesIfNecessary: Bool = true, using fileManager: FileManager = .default) throws {
        try self.init(fileAt: URL(fileURLWithPath: filePath), createIntermediatesIfNecessary: createIntermediatesIfNecessary, using: fileManager)
    }
    
    
    /// Creates a new file log channel using the file at the given location
    /// 
    /// - Attention: The path URL _must_ point to a local file; this log channel location is not made for network communications.
    ///
    /// - Parameters:
    ///   - pathUrl: The file URL with a path to the file which will accept the logging.
    ///   - createIntermediatesIfNecessary: _optional_ - If the parent directory, or any of its ancestor directories, doesn't exist, then passing `true` will cause this to attempt to create it, whereas if you pass `false`, then this will throw an error if they don't exist. Defaults to `true`.
    ///   - fileManager: _optional_ - The file manager to use when performing file system operations. Defaults to `.default`.
    ///
    /// - Throws: If the parent directory cannot be created, or if you specified that it shouldn't be but it doesn't exist, or if the log file cannot ce created, or if the file couldn't be opened for writing
    public init(fileAt pathUrl: URL, createIntermediatesIfNecessary: Bool = true, using fileManager: FileManager = .default) throws {
        let parentDirectory = pathUrl.deletingLastPathComponent()
        
        do {
            try fileManager.createDirectory(at: parentDirectory, withIntermediateDirectories: createIntermediatesIfNecessary, attributes: nil)
        }
        catch {
            print(error)
            assertionFailure("Could not create file parent directory: " + error.localizedDescription)
            throw error
        }
        
        let path = pathUrl.path
        
        guard fileManager.createFile(atPath: path, contents: nil, attributes: nil) else {
            assertionFailure("Could not create file")
            throw CreateError.couldNotCreateLogFile(path: path)
        }
        
        do {
            self.fileHandle = try FileHandle(forWritingTo: pathUrl)
        }
        catch {
            assertionFailure("Could not create file handle pointing to \(path): " + error.localizedDescription)
            throw error
        }
    }
    
    
    public func append(_ message: LogMessageProtocol, options: LoggingOptions) {
        print(message.entireRenderedLogLine(options: options), to: &fileHandle)
    }
    
    
    
    /// An error which might occur while attempting to create a file log channel
    enum CreateError: Error {
        
        /// Thrown when you want to log to a file, but that file could not be created
        case couldNotCreateLogFile(path: String)
    }
}



public extension UnreliableLogChannelLocation where Self == FileLogChannelLocation {
    
    /// Directs log messages to a text file – new log lines will be appended
    ///
    /// - Parameters:
    ///   - filePath:                       The path to the file which will accept the logging
    ///   - createIntermediatesIfNecessary: _optional_ - If the parent directory, or any of its ancestor directories, doesn't exist, then passing `true` will cause this to attempt to create it, whereas if you pass `false`, then this will throw an error if they don't exist. Defaults to `true`.
    ///   - fileManager:                    _optional_ - The file manager to use when performing file system operations. Defaults to `.default`.
    ///
    /// - Throws: If the parent directory cannot be created, or if you specified that it shouldn't be but it doesn't exist, or if the log file cannot ce created, or if the file couldn't be opened for writing
    static func file(path: String, createIntermediatesIfNecessary: Bool = true, using fileManager: FileManager = .default) throws -> Self {
        try .init(filePath: path,
                  createIntermediatesIfNecessary: createIntermediatesIfNecessary,
                  using: fileManager)
    }
    
    /// Directs log messages to a text file – new log lines will be appended
    ///
    /// - Attention: The path URL _must_ point to a local file; this log channel location is not made for network communications.
    ///
    /// - Parameters:
    ///   - pathUrl:                        The file URL with a path to the file which will accept the logging.
    ///   - createIntermediatesIfNecessary: _optional_ - If the parent directory, or any of its ancestor directories, doesn't exist, then passing `true` will cause this to attempt to create it, whereas if you pass `false`, then this will throw an error if they don't exist. Defaults to `true`.
    ///   - fileManager:                    _optional_ - The file manager to use when performing file system operations. Defaults to `.default`.
    ///
    /// - Throws: If the parent directory cannot be created, or if you specified that it shouldn't be but it doesn't exist, or if the log file cannot ce created, or if the file couldn't be opened for writing
    static func file(fileAt pathUrl: URL, createIntermediatesIfNecessary: Bool = true, using fileManager: FileManager = .default) throws -> Self {
        try .init(fileAt: pathUrl,
                  createIntermediatesIfNecessary: createIntermediatesIfNecessary,
                  using: fileManager)
    }
}



public extension LogChannel where Location == FileLogChannelLocation {
    
    /// Creates a new file log channel using the file at the given path
    ///
    /// - Parameters:
    ///   - filePath:                        The path to the file which will accept the logging
    ///   - createIntermediatesIfNecessary: _optional_ - If the parent directory, or any of its ancestor directories, doesn't exist, then passing `true` will cause this to attempt to create it, whereas if you pass `false`, then this will throw an error if they don't exist. Defaults to `true`.
    ///   - fileManager:                     _optional_ - The file manager to use when performing file system operations. Defaults to `.default`.
    ///   - name:                            _optional_ - The human-readable name of the channel. Pass `nil` to generate one based on the path. Defaults to `nil`.
    ///   - severityFilter:                  _optional_ - The filter which decides which messages appear in this channel's logs. Defaults to allowing `info` and higher, since `info` is the lowest built-in severity which users might care about if they're looking at logs, but not debugging the code itself.
    ///   - logSeverityNameStyle:            _optional_ - The style of the severity names that appear in the log. Defaults to `.emoji`, so humans can more easily skim the log.
    ///
    /// - Throws: If the parent directory cannot be created, or if you specified that it shouldn't be but it doesn't exist, or if the log file cannot ce created, or if the file couldn't be opened for writing
    static func file(
        atPath filePath: String,
        createIntermediatesIfNecessary: Bool = true,
        using fileManager: FileManager = .default,
        name: String? = nil,
        severityFilter: LogSeverityFilter = .default,
        logSeverityNameStyle: SeverityNameStyle = .default)
    throws -> Self {
        LogChannel(
            name: name ?? URL(fileURLWithPath: filePath).lastPathComponent,
            location: try FileLogChannelLocation(
                filePath: filePath,
                createIntermediatesIfNecessary: createIntermediatesIfNecessary,
                using: fileManager),
            severityFilter: severityFilter,
            logSeverityNameStyle: logSeverityNameStyle)
        
    }
    
    
    /// Creates a new file log channel using the file at the given path
    ///
    /// - Parameters:
    ///   - filePath:                        The path to the file which will accept the logging
    ///   - createIntermediatesIfNecessary: _optional_ - If the parent directory, or any of its ancestor directories, doesn't exist, then passing `true` will cause this to attempt to create it, whereas if you pass `false`, then this will throw an error if they don't exist. Defaults to `true`.
    ///   - fileManager:                     _optional_ - The file manager to use when performing file system operations. Defaults to `.default`.
    ///   - name:                            _optional_ - The human-readable name of the channel. Pass `nil` to generate one based on the path. Defaults to `nil`.
    ///   - lowestAllowedSeverity:           _optional_ - The lowest severity which will appear in this channel's logs. Defaults to `info`, since that's the lowest built-in severity which users might care about if they're looking at logs, but not debugging the code itself.
    ///   - logSeverityNameStyle:            _optional_ - The style of the severity names that appear in the log. Defaults to `.emoji`, so humans can more easily skim the log.
    ///
    /// - Throws: If the parent directory cannot be created, or if you specified that it shouldn't be but it doesn't exist, or if the log file cannot ce created, or if the file couldn't be opened for writing
    static func file(
        atPath filePath: String,
        createIntermediatesIfNecessary: Bool = true,
        using fileManager: FileManager = .default,
        name: String? = nil,
        lowestAllowedSeverity: LogSeverity,
        logSeverityNameStyle: SeverityNameStyle = .default)
    throws -> Self {
        LogChannel(
            name: name ?? URL(fileURLWithPath: filePath).lastPathComponent,
            location: try FileLogChannelLocation(
                filePath: filePath,
                createIntermediatesIfNecessary: createIntermediatesIfNecessary,
                using: fileManager),
            lowestAllowedSeverity: lowestAllowedSeverity,
            logSeverityNameStyle: logSeverityNameStyle)
        
    }
    
    
    /// Creates a new file log channel using the file at the given location
    ///
    /// - Attention: The path URL _must_ point to a local file; this log channel location is not made for network communications.
    ///
    /// - Parameters:
    ///   - pathUrl:                         The file URL with a path to the file which will accept the logging.
    ///   - createIntermediatesIfNecessary: _optional_ - If the parent directory, or any of its ancestor directories, doesn't exist, then passing `true` will cause this to attempt to create it, whereas if you pass `false`, then this will throw an error if they don't exist. Defaults to `true`.
    ///   - fileManager:                     _optional_ - The file manager to use when performing file system operations. Defaults to `.default`.
    ///   - name:                            _optional_ - The human-readable name of the channel. Pass `nil` to generate one based on the path. Defaults to `nil`.
    ///   - severityFilter:                  _optional_ - The filter which decides which messages appear in this channel's logs. Defaults to allowing `info` and higher, since `info` is the lowest built-in severity which users might care about if they're looking at logs, but not debugging the code itself.
    ///   - logSeverityNameStyle:            _optional_ - The style of the severity names that appear in the log. Defaults to `.emoji`, so humans can more easily skim the log.
    ///
    /// - Throws: If the parent directory cannot be created, or if you specified that it shouldn't be but it doesn't exist, or if the log file cannot ce created, or if the file couldn't be opened for writing
    static func file(
        at fileUrl: URL,
        createIntermediatesIfNecessary: Bool = true,
        using fileManager: FileManager = .default,
        name: String? = nil,
        severityFilter: LogSeverityFilter = .default,
        logSeverityNameStyle: SeverityNameStyle = .default)
    throws -> Self {
        LogChannel(
            name: name ?? fileUrl.lastPathComponent,
            location: try FileLogChannelLocation(
                fileAt: fileUrl,
                createIntermediatesIfNecessary: createIntermediatesIfNecessary,
                using: fileManager),
            severityFilter: severityFilter,
            logSeverityNameStyle: logSeverityNameStyle)
        
    }
    
    
    /// Creates a new file log channel using the file at the given location
    ///
    /// - Attention: The path URL _must_ point to a local file; this log channel location is not made for network communications.
    ///
    /// - Parameters:
    ///   - pathUrl:                         The file URL with a path to the file which will accept the logging.
    ///   - createIntermediatesIfNecessary: _optional_ - If the parent directory, or any of its ancestor directories, doesn't exist, then passing `true` will cause this to attempt to create it, whereas if you pass `false`, then this will throw an error if they don't exist. Defaults to `true`.
    ///   - fileManager:                     _optional_ - The file manager to use when performing file system operations. Defaults to `.default`.
    ///   - name:                            _optional_ - The human-readable name of the channel. Pass `nil` to generate one based on the path. Defaults to `nil`.
    ///   - lowestAllowedSeverity:           _optional_ - The lowest severity which will appear in this channel's logs. Defaults to `info`, since that's the lowest built-in severity which users might care about if they're looking at logs, but not debugging the code itself.
    ///   - logSeverityNameStyle:            _optional_ - The style of the severity names that appear in the log. Defaults to `.emoji`, so humans can more easily skim the log.
    ///
    /// - Throws: If the parent directory cannot be created, or if you specified that it shouldn't be but it doesn't exist, or if the log file cannot ce created, or if the file couldn't be opened for writing
    static func file(
        at fileUrl: URL,
        createIntermediatesIfNecessary: Bool = true,
        using fileManager: FileManager = .default,
        name: String? = nil,
        lowestAllowedSeverity: LogSeverity,
        logSeverityNameStyle: SeverityNameStyle = .default)
    throws -> Self {
        LogChannel(
            name: name ?? fileUrl.lastPathComponent,
            location: try FileLogChannelLocation(
                fileAt: fileUrl,
                createIntermediatesIfNecessary: createIntermediatesIfNecessary,
                using: fileManager),
            lowestAllowedSeverity: lowestAllowedSeverity,
            logSeverityNameStyle: logSeverityNameStyle)
        
    }
}
