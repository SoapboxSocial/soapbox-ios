import Alamofire
import Foundation
import KeychainAccess

class RoomAPIClient: Client {
    struct Member: Decodable {
        let id: Int
        let displayName: String
        let image: String

        private enum CodingKeys: String, CodingKey {
            case id, displayName = "display_name", image
        }
    }

    struct Room: Decodable {
        enum Visibility: String, Decodable {
            case `public`, `private`
        }

        let id: String
        let name: String
        let visibility: Visibility
        let members: [Member]
    }

    init() {
        super.init(url: Configuration.roomAPIURL)
    }

    func rooms(callback: @escaping (Result<[Room], Error>) -> Void) {
        get(path: "/v1/rooms", callback: callback)
    }

    func room(id: String, callback: @escaping (Result<Room, Error>) -> Void) {
        get(path: "/v1/rooms/" + id, callback: callback)
    }
}
