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

    static let websocketURL: URL = {
        url(key: "WEBSOCKET_URL")
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
