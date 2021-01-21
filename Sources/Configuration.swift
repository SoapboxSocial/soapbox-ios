import Foundation

class Configuration {
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }

        return dict
    }()

    static let rootURL: URL = {
        url(key: "ROOT_URL")
    }()

    static let cdn: URL = {
        url(key: "CDN_URL")
    }()

    static let roomAPIURL = {
        url(key: "ROOM_API_URL")
    }()

    static let roomServiceURL: String = {
        guard let urlString = Configuration.infoDictionary["ROOM_SERVICE_URL"] as? String else {
            fatalError("ROOM_SERVICE_URL not set in plist for this environment")
        }

        return urlString
    }()

    static let roomServicePort: Int = {
        guard let value = Configuration.infoDictionary["ROOM_SERVICE_PORT"] as? String else {
            fatalError("ROOM_SERVICE_PORT not set in plist for this environment")
        }

        guard let port = Int(value) else {
            fatalError("\(value) could not be converted")
        }

        return port
    }()

    private static func url(key: String) -> URL {
        guard let urlString = Configuration.infoDictionary[key] as? String else {
            fatalError("\(key) not set in plist for this environment")
        }

        guard let url = URL(string: urlString) else {
            fatalError("\(key) URL is invalid")
        }

        return url
    }
}
