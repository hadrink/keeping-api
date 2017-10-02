import MongoKitten
import Foundation

struct UsersServices: Services {
    static let db = try? KIEnvironment.prod.database()
    static var collection = db?[KICollections.users.rawValue]

    static func getUsersDocumentBy(name: String) -> CollectionSlice<Document>? {
        do {
            return try collection?.find("Name" == name)
        } catch let e {
            print("Get user by name error: \(e)")
            return nil
        }
    }
}
