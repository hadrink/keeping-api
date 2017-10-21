//
//  User.swift
//  KeepinServices
//
//  Created by Rplay on 21/10/2017.
//
import Foundation
import MongoKitten

enum UserError: Error {
    case usernameAlreadyExist(message: String)
}

final class User {
    var username: String
    var password: String

    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    func create() throws {
        let existingUser = UsersServices.getUserDocumentBy(username: self.username)
        guard existingUser == nil else {
            let message = "Username \(self.username) already exist"
            throw UserError.usernameAlreadyExist(message: message)
        }

        let userDocument: Document = [
            "username":  self.username,
            "password": self.password
        ]

        UsersServices.create(document: userDocument)
    }
}
