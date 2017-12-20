//
//  Room.swift
//  KeepinAPI
//
//  Created by Rplay on 20/12/2017.
//

import Foundation
import Vapor

/// Room model
final class Room {

    var roomName: String

    /**
     Connections.
     */
    var connections: [String: WebSocket] = [:]

    /**
     Message return by a bot.
     - parameter message: The content.
     */
    func bot(_ message: String) {
        sendBy(name: "Bot", message: message)
    }

    /**
     Send message to a specific room name.
     - parameter name: Room name.
     - parameter message: The content.
     */
    func sendBy(name: String, message: String) {
        let message = message.truncated(to: 256)

        let messageNode: [String: NodeRepresentable] = [
            "username": name,
            "message": message
        ]

        guard let json = try? JSON(node: messageNode) else {
            return
        }

        for (username, socket) in connections {
            try? socket.send(json)
        }
    }

    init(roomName: String) {
        self.roomName = roomName
    }
}
