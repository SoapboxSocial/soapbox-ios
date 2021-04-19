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
