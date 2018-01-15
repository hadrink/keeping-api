//
//  Server.swift
//  KeepinServer
//
//  Created by Rplay on 14/01/2018.
//

import Vapor

/**
 Server config
 */
public var config: Config? = {
    do {
        return try Config()
    } catch let e {
        print(e)
        return nil
    }
}()

/**
 Droplet, handle requests.
 */
public var drop: Droplet? = {
    do {
        guard let config = config else {
            return nil
        }

        return try Droplet(config)
    } catch let e {
        print(e)
        return nil
    }
}()


