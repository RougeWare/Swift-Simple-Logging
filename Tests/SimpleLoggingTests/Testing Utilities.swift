//
//  Testing Utilities.swift
//  
//
//  Created by Ky on 2022-01-31.
//

import Foundation
import SimpleLogging



let date = #"\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z"#



enum TestError: String, LoggableError {
    case neverThrown = "This error is logged but never thrown"
    case thrownFromInsideTestFunction = "This error is only thrown from inside a test function"
    
    var description: String {
        return rawValue
    }
}



func alwaysThrows() throws -> UInt {
    throw TestError.thrownFromInsideTestFunction
}



func neverThrows(_ return: UInt) -> UInt { `return` }



extension NSRegularExpression {
    convenience init(wholeStringPattern: String) {
        try! self.init(pattern: "^\(wholeStringPattern)$")
    }
}
