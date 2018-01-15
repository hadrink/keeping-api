//
//  Claims.swift
//  KeepinServer
//
//  Created by Rplay on 31/10/2017.
//
import Vapor
import AuthProvider
import JWT

/// Claims.
public class Claims: JSONInitializable {
    var subjectClaimValue : String
    var expirationTimeClaimValue : Double

    public required init(json: JSON) throws {
        guard let subjectClaimValue = try json.get(SubjectClaim.name) as String? else {
            throw AuthenticationError.invalidCredentials
        }
        self.subjectClaimValue = subjectClaimValue

        guard let expirationTimeClaimValue = try json.get(ExpirationTimeClaim.name) as String? else {
            throw AuthenticationError.invalidCredentials
        }
        self.expirationTimeClaimValue = Double(expirationTimeClaimValue)!
    }
}
