//
//  StringExtensions.swift
//  KeepinServer
//
//  Created by Rplay on 20/12/2017.
//

import Foundation

extension String {
    func truncated(to max: Int) -> String {
        guard self.count > max else {
            return self
        }

        return String(self[..<index(startIndex, offsetBy: max)])
    }

    /**
     Generate a random text.
     - parameter length: Define the random text length.
     - parameter justLowerCase: Lower case only if true.
     - returns: A random ACSII string (String).
     */
    static func randomText(length: Int, justLowerCase: Bool = false) -> String {
        var text = ""
        for _ in 1...length {
            var decValue = 0  // ascii decimal value of a character
            var charType = 3  // default is lowercase
            if justLowerCase == false {
                // randomize the character type
                charType =  Int.random(min: 0, max: 10)
            }
            switch charType {
            case 1:  // digit: random Int between 48 and 57
                decValue = Int.random(min: 0, max: 10) + 48

            case 2:  // uppercase letter
                decValue = Int.random(min: 0, max: 26) + 65
            case 3:  // lowercase letter
                decValue = Int.random(min: 0, max: 26) + 97
            default:  // space character
                decValue = 32
            }
            // get ASCII character from random decimal value
            let char = String(UnicodeScalar(decValue)!)
            text = text + char
            // remove double spaces
            text = text.replacingOccurrences(of: "  ", with: " ")
        }
        return text
    }
}
