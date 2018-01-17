//
//  Validators.swift
//  KeepinServer
//
//  Created by Rplay on 17/01/2018.
//

import Validation
import Vapor

public struct NameValidator: Validator {

    public func validate(_ input: String) throws {
        try ASCIIValidator().validate(input)

        guard input.count < 25 else {
            throw error("\(input) is limited to 24 characters.")
        }
    }
}
