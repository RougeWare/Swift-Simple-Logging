//
//  FileHandle + TextOutputStream.swift
//  SimpleLogging
//
//  Created by Ky Leggiero on 2020-05-18.
//

import Foundation



extension FileHandle: TextOutputStream {
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        self.write(data)
    }
}



internal var standardOutput = FileHandle.standardOutput
internal var standardError = FileHandle.standardError
