//
//  Room.swift
//  KeepinServer
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
     Some messages in cache.
     */
    var cache: [JSON] = []

    /**
     Last message received.
     */
    var lastMessageReceived: JSON? {
        get {
            return self.cache.last
        }

        set(newMessage) {
            guard let message = newMessage else {
                return
            }

            guard self.cache.count > 99 else {
                self.cache.append(message)
                return
            }

            self.cache.remove(at: 0)
            self.cache.append(message)
        }
    }

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
            "message": message,
            "date": Date()
        ]

        guard let json = try? JSON(node: messageNode) else {
            return
        }

        self.lastMessageReceived = json

        for (username, socket) in connections {
            try? socket.send(json)
        }

    }

    /**
     Send messages in cache to a websocket.
     - parameter socket: Websocket.
     */
    func sendMessagesInCacheTo(socket: WebSocket) {
        cache.forEach({ json in
            try? socket.send(json)
        })
    }

    /**
     Send a server notiication to a specific room name.
     - parameter notification: Server notification (String).
     */
    func sendServerNotification(_ notification: String) {
        let notificationNode: [String: NodeRepresentable] = [
            "server_notification": notification
        ]

        guard let json = try? JSON(node: notificationNode) else {
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
