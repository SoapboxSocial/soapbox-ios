import UIKit
import WebKit

class MiniAppView: UIView {
    enum Query: String, CaseIterable {
        case room, user, members
    }

    struct UserData: Codable {
        let displayName: String
        let id: Int
        let image: String

        private enum CodingKeys: String, CodingKey {
            case id, displayName = "display_name", image
        }
    }

    struct RoomData: Encodable {
        let id: String
        let name: String
    }

    enum ResponseData: Encodable {
        case room(RoomData), user(UserData), members([UserData])

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case let .room(value):
                try container.encode(value)
            case let .user(value):
                try container.encode(value)
            case let .members(value):
                try container.encode(value)
            }
        }
    }

    struct Response: Encodable {
        let sequence: Int64
        let data: ResponseData
    }

    private let room: Room

    private let encoder = JSONEncoder()

    private let webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
//        @TODO
//        config.limitsNavigationsToAppBoundDomains = true
        config.preferences.javaScriptEnabled = true

        let view = WKWebView(frame: .zero, configuration: config)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(app _: String, room: Room) {
        self.room = room

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        layer.cornerRadius = 10
        layer.masksToBounds = true
        clipsToBounds = true

        backgroundColor = .clear
        webView.backgroundColor = .clear

        addSubview(webView)

        for event in Query.allCases {
            webView.configuration.userContentController.add(self, name: event.rawValue)
        }

        NSLayoutConstraint.activate([
            webView.leftAnchor.constraint(equalTo: leftAnchor),
            webView.rightAnchor.constraint(equalTo: rightAnchor),
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        webView.load(URLRequest(url: URL(string: "https://soapbox-apps.vercel.app/polls?roomID=\(room.state.id)")!))
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func respond(_ type: Query, sequence: Int64, data: ResponseData) {
        do {
            let response = Response(sequence: sequence, data: data)
            let encoded = try encoder.encode(response)

            let eval = String(format: "window.mitt.emit(\"%@\", %@);", type.rawValue, String(data: encoded, encoding: .utf8)!)
            webView.evaluateJavaScript(eval, completionHandler: { result, error in
                if result != nil { // @TODO
                    debugPrint("fucking \(error)")
                    return
                }

                if error != nil {
                    debugPrint("fuck \(error)")
                    // @TODO
                }
            })
        } catch {
            debugPrint("error \(error)")
        }
    }
}

// @TODO WE NEED ACCESS CONTROL FOR THIS, WE NEED TO FIGURE OUT HOW ONLY THE ROOM KING OR WHATEVER SHOULD RESPOND
extension MiniAppView: WKScriptMessageHandler {
    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let event = Query(rawValue: message.name) else {
            return
        }

        guard let body = message.body as? [String: Any] else {
            return
        }

        guard let sequence = body["sequence"] as? NSNumber else {
            return
        }

        switch event {
        case .room:
            respond(event, sequence: sequence.int64Value, data: .room(RoomData(id: room.state.id, name: room.state.name)))
        case .user:
            let user = UserStore.get()

            respond(
                event,
                sequence: sequence.int64Value,
                data: .user(UserData(displayName: user.displayName, id: user.id, image: user.image ?? ""))
            )
        case .members:
            let members = room.state.members.map {
                UserData(displayName: $0.displayName, id: Int($0.id), image: $0.image)
            }
            
            respond(event, sequence: sequence.int64Value, data: .members(members))
        }
    }
}
