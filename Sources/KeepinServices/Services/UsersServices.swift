import MongoKitten
import Foundation

/// Users Services.
struct UsersServices: Services {
    static let db = try? KIEnvironment.prod.database()
    static var collection = db?[KICollections.users.rawValue]

    /**
     Get user document by principal.
     - parameter principal: The user principal (String).
     - returns: The user document (Document?).
     */
    static func getUserDocumentBy(principal: String) -> Document? {
        do {
            return try collection?.findOne("principal" == principal)
        } catch let e {
            print("Get user by principal error: \(e)")
            return nil
        }
    }
}
