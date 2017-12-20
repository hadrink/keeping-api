//
//  StringExtensions.swift
//  KeepinAPI
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
}
