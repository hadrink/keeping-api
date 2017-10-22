//
//  main.swift
//  KeepinAPI
//
//  Created by Rplay on 09/10/2017.
//


// Find a way to add a flag during the compilation.
// For example: swift build -c debug -Xswiftc -DQA
import Vapor

#if QA
print("hello, world");
#endif

let drop = try Droplet()

// will load 0.0.0.0 or 127.0.0.1 based on above config
let host = drop.config["server", "host"]?.string ?? "0.0.0.0"
// will load 9000, or environment variable port.
let port = drop.config["server", "port"]?.int ?? 8080


let userRoutes = UsersRoutes()
let registrationRoutes = RegistationRoutes()
Router.run(drop: drop, from: [userRoutes, registrationRoutes])
