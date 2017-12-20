//
//  WebsocketExtensions.swift
//  KeepinAPI
//
//  Created by Rplay on 20/12/2017.
//

import Vapor

extension WebSocket {
    func send(_ json: JSON) throws {
        let js = try json.makeBytes()
        try send(js.makeString())
    }
}
