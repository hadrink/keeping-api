//
//  ConfigExtensions.swift
//  KeepinAPI
//
//  Created by Rplay on 01/11/2017.
//

import AuthProvider
import JWTProvider
import Vapor

/// Config extension.
extension Config {

    /**
     Setup.
     */
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [JSON.self, Node.self]
        try setupProviders()
    }

    /**
     Setup Providers.
     */
    private func setupProviders() throws {
        try addProvider(AuthProvider.Provider.self)
        try addProvider(JWTProvider.Provider.self)
    }
}
