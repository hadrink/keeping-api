//
//  RoomController.swift
//  KeepinServer
//
//  Created by Rplay on 20/12/2017.
//

import Vapor
import Foundation
import AuthProvider
import Dispatch

/// Chat controller
final class ChatController {

    init(communityController: CommunityController) {
        communityController.delegate = self
    }

    /*
     All rooms.
     */
    var rooms: Array<Room> = []

    var roomsSortedByActivity: Array<Room> {
        return self.rooms.sorted(by: { $0.connections.count > $1.connections.count })
    }

    /**
     Handle sockets.
     - parameter req: The http request.
     - parameter ws: The user websocket.
     */
    func handler(req: Request, ws: WebSocket) {
        var pingTimer: DispatchSourceTimer?
        var room: Room?
        var connection: SocketConnection?

        pingTimer = DispatchSource.makeTimerSource()
        pingTimer?.schedule(deadline: .now(), repeating: .seconds(25))
        pingTimer?.setEventHandler { try? ws.ping() }
        pingTimer?.resume()

        ws.onText = { ws, text in
            let json = try JSON(bytes: text.makeBytes())

            guard let roomName = json.object?["communityName"]?.string else {
                return 
            }

            let roomsFound = self.rooms.filter{$0.roomName == roomName}
            room = roomsFound.count > 0 ? roomsFound.first : Room(roomName: roomName)
            self.rooms.append(room!)

            if connection == nil, let token = json.object?["token"]?.string {
                let user = try User.authenticate(Token(string: token))
                connection = SocketConnection(username: user.username, socket: ws)
                room?.connections.append(connection!)
                room?.sendMessagesInCacheTo(socket: ws)
            }

            if connection == nil, json.object?["token"] == nil {
                let connection = SocketConnection(socket: ws)
                room?.connections.append(connection)
                room?.sendMessagesInCacheTo(socket: ws)
            }

            if let u = connection?.username, let m = json.object?["message"]?.string {
                room?.sendBy(name: u, message: m)
            }

            if let u = connection?.username, let n = json.object?["notification"]?.string, let r = room {
                let user = try User(username: u)
                let community = Community(name: r.roomName)

                guard try user.isAdmin(community: community) else {
                    return
                }

                r.sendServerNotification(n)
            }
        }

        ws.onClose = { ws, _, _, _ in
            pingTimer?.cancel()
            pingTimer = nil

            guard let c = connection else {
                return
            }

            guard let r = room?.roomName else {
                return
            }

            room?.bot("\(String(describing: c.username)) has left the \(r) community.")

            guard let connectionId = room?.connections.index(where: {$0.id == connection?.id}) else {
                return
            }

            room?.connections.remove(at: connectionId)

            guard room?.connections.count == 0 else {
                return
            }

            guard let i = self.rooms.index(where: { $0.roomName == r }) else {
                return
            }

            self.rooms.remove(at: i)
        }
    }

    /**
     Send a server notification to a room.
     - parameter notification: Message to send (String).
     - parameter roomName: Room (String).
     */
    func sendNotification(_ notification: String, to roomName: String) {
        let roomsFound = self.rooms.filter{$0.roomName == roomName}

        guard roomsFound.count > 0 else {
            return
        }

        roomsFound.first?.sendServerNotification(notification)
    }
}

extension ChatController: CommunityControllerDelegate {

    func requestSortedCommunitiesByActivity(limit: Int) throws -> ResponseRepresentable {
        let count = self.roomsSortedByActivity.count
        let limit = count < limit ? count : limit
        let communities = self.roomsSortedByActivity[0..<limit].map({(room: Room) -> Community in
            return Community(name: room.roomName)
        })

        return try Community.get(communities: communities)
    }
}
