import MongoKitten
import Foundation

// Environment setup
enum KIEnvironment {
    case prod
    case qa
    case test

    func database() throws -> Database {
        do {
            switch self {
            case .prod:
                return try Database("mongodb://localhost/keepin")
            default:
                return try Database("mongodb://localhost/keepin")
            }
        } catch let e {
            throw(e)
        }
    }
}
