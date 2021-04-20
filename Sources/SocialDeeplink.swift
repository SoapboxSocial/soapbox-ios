import UIKit

class SocialDeeplink {
    enum Platform: String, CaseIterable {
        case twitter, whatsapp, telegram

        var scheme: String {
            switch self {
            case .twitter:
                return "twitter://"
            case .whatsapp:
                return "whatsapp://"
            case .telegram:
                return "tg://"
            }
        }

        var post: String {
            switch self {
            case .twitter:
                return "twitter://post?message=%@"
            case .whatsapp:
                return "whatsapp://send?text=%@"
            case .telegram:
                return "tg://msg?text=%@"
            }
        }

        var color: UIColor {
            switch self {
            case .telegram:
                return UIColor(red: 0 / 255, green: 136 / 255, blue: 204 / 255, alpha: 1.0)
            case .twitter:
                return UIColor(red: 29 / 255, green: 161 / 255, blue: 242 / 255, alpha: 1.0)
            case .whatsapp:
                return UIColor(red: 79 / 255, green: 206 / 255, blue: 93 / 255, alpha: 1.0)
            }
        }
    }

    static func canOpen(platform: Platform) -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: platform.scheme)!)
    }

    static func open(platform: Platform, message: String) {
        guard let url = URL(string: String(format: platform.post, message)) else {
            return
        }

        UIApplication.shared.open(url)
    }
}
