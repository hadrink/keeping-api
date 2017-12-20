//
//  RoomController.swift
//  KeepinAPI
//
//  Created by Rplay on 20/12/2017.
//

import Vapor
import Foundation

/// Chat controller
class ChatController {

    /*
     All rooms.
     */
    var rooms: Array<Room> = []

    /**
     Handle sockets.
     - parameter req: The http request.
     - parameter ws: The user websocket.
     */
    func handler(req: Request, ws: WebSocket) {
        var pingTimer: DispatchSourceTimer? = nil
        var username: String? = nil
        var room: Room?

        pingTimer = DispatchSource.makeTimerSource()
        pingTimer?.scheduleRepeating(deadline: .now(), interval: .seconds(25))
        pingTimer?.setEventHandler { try? ws.ping() }
        pingTimer?.resume()

        ws.onText = { ws, text in
            let json = try JSON(bytes: text.makeBytes())

            guard let roomName = json.object?["communityName"]?.string else {
                return 
            }

            let roomsFound = self.rooms.filter{$0.roomName == roomName}
            room = roomsFound.count > 0 ? roomsFound[0] : Room(roomName: roomName)
            self.rooms.append(room!)

            if let u = json.object?["username"]?.string {
                username = u
                room?.connections[u] = ws
                room?.bot("\(u) has joined. 👋")
            }

            if let u = username, let m = json.object?["message"]?.string {
                room?.sendBy(name: u, message: m)
            }
        }

        ws.onClose = { ws, _, _, _ in
            pingTimer?.cancel()
            pingTimer = nil

            guard let u = username else {
                return
            }

            guard let r = room?.roomName else {
                return
            }

            room?.bot("\(u) has left the \(r) community.")
            room?.connections.removeValue(forKey: u)

            guard room?.connections.count == 0 else {
                return
            }

            guard let i = self.rooms.index(where: { $0.roomName == r }) else {
                return
            }

            self.rooms.remove(at: i)
        }
    }
}
