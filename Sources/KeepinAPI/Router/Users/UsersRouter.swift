//
//  Users.swift
//  KeepinAPI
//
//  Created by Rplay on 09/10/2017.
//

import Foundation
import Vapor

protocol Routes {
    //var drop: Droplet? { get set }
    func build(with drop: Droplet)
}

class UsersRoutes: Routes {
    func build(with drop: Droplet) {
        drop.get("user") { req in
            return "Hello user router"
        }
    }
}

struct Router {

    static func run(drop: Droplet, from routers: Array<Routes>) {
        routers.forEach{$0.build(with: drop)}
        try! drop.run()
    }
}
