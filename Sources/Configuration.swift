import Foundation

class Configuration {
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }

        return dict
    }()

    static let rootURL: URL = {
        guard let rootURLstring = Configuration.infoDictionary["ROOT_URL"] as? String else {
            fatalError("Root URL not set in plist for this environment")
        }

        guard let url = URL(string: rootURLstring) else {
            fatalError("Root URL is invalid")
        }

        return url
    }()

    static let cdn: URL = {
        guard let cdnURLstring = Configuration.infoDictionary["CDN_URL"] as? String else {
            fatalError("CDN URL not set in plist for this environment")
        }

        guard let url = URL(string: cdnURLstring) else {
            fatalError("CDN URL is invalid")
        }

        return url
    }()
}
