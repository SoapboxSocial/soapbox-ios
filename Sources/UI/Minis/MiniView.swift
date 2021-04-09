import UIKit
import WebKit

protocol MiniViewDelegate: AnyObject {
    func didTapCloseMiniView(_ view: MiniView)
}

class MiniView: UIView {
    enum Query: String, CaseIterable {
        case room, user, members
    }

    enum Event: String, CaseIterable {
        case room, user, members, closed
    }

    struct UserData: Codable {
        let displayName: String
        let id: Int
        let image: String
        let username: String

        private enum CodingKeys: String, CodingKey {
            case id, displayName = "display_name", image, username
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

    private let content: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 5
        stack.distribution = .fill
        stack.alignment = .fill
        stack.axis = .vertical
        return stack
    }()

    private let webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
//        @TODO
//        config.limitsNavigationsToAppBoundDomains = true
        config.preferences.javaScriptEnabled = true
        config.suppressesIncrementalRendering = true

        let view = WKWebView(frame: .zero, configuration: config)
        view.isOpaque = false
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        return view
    }()

    private let exitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark.circle", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), for: .normal)
        button.tintColor = .systemRed
        button.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        return button
    }()

    private let buttonView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var delegate: MiniViewDelegate?

    init(app: Soapbox_V1_RoomState.Mini, room: Room, appOpener: Bool = false) {
        self.room = room

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .clear

        addSubview(loadingIndicator)
        addSubview(content)

        webView.navigationDelegate = self

        buttonView.addSubview(exitButton)

        content.addArrangedSubview(webView)
        content.addArrangedSubview(buttonView)

        for event in Query.allCases {
            webView.configuration.userContentController.add(WKScriptMessageHandlerLeakAvoider(self), name: event.rawValue)
        }

        #if DEBUG
            let source = "function captureLog(msg) { window.webkit.messageHandlers.logHandler.postMessage(msg); } window.console.log = captureLog;"
            let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            webView.configuration.userContentController.addUserScript(script)
            webView.configuration.userContentController.add(WKScriptMessageHandlerLeakAvoider(self), name: "logHandler")
        #endif

        NSLayoutConstraint.activate([
            buttonView.leftAnchor.constraint(equalTo: leftAnchor),
            buttonView.rightAnchor.constraint(equalTo: rightAnchor),
            buttonView.heightAnchor.constraint(equalToConstant: 20),
        ])

        NSLayoutConstraint.activate([
            exitButton.widthAnchor.constraint(equalToConstant: 20),
            exitButton.heightAnchor.constraint(equalToConstant: 20),
            exitButton.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 5),
            exitButton.leftAnchor.constraint(equalTo: content.leftAnchor),
        ])

        NSLayoutConstraint.activate([
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])

        NSLayoutConstraint.activate([
            content.leftAnchor.constraint(equalTo: leftAnchor),
            content.rightAnchor.constraint(equalTo: rightAnchor),
            content.topAnchor.constraint(equalTo: topAnchor),
            content.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        guard var url = URL(string: "https://apps.soapbox.social\(app.slug)") else {
            return
        }

        url.appendQueryParameters(["roomID": room.state.id])

        if appOpener {
            url.appendQueryParameters(["isAppOpener": "true"])
        }

        webView.load(URLRequest(url: url))

        let id = UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId)
        guard let user = room.state.members.first(where: { $0.id == Int64(id) }) else {
            return
        }

        adminRoleChanged(isAdmin: user.role == .admin)
    }

    func adminRoleChanged(isAdmin: Bool) {
        if isAdmin {
            buttonView.isHidden = false
        } else {
            buttonView.isHidden = true
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func respond(_ event: Event, sequence: Int64, data: ResponseData) {
        do {
            let response = Response(sequence: sequence, data: data)
            let encoded = try encoder.encode(response)
            write(event, data: String(data: encoded, encoding: .utf8)!)
        } catch {
            debugPrint("error \(error)")
        }
    }

    private func write(_ event: Event, data: String, completion: (() -> Void)? = nil) {
        let eval = String(format: "window.mitt.emit(\"%@\", %@);", event.rawValue, data)
        webView.evaluateJavaScript(eval, completionHandler: { result, error in
            if let completion = completion {
                completion()
            }

            if result != nil {
                return
            }

            if error != nil {
                debugPrint("evaluteJavaScript error \(error!)")
            }
        })
    }
}

extension MiniView: WKScriptMessageHandler {
    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        #if DEBUG
            if message.name == "logHandler" {
                return debugPrint("console.log: \(message.body)")
            }
        #endif

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
            respond(.room, sequence: sequence.int64Value, data: .room(RoomData(id: room.state.id, name: room.state.name)))
        case .user:
            let user = UserStore.get()

            respond(
                .user,
                sequence: sequence.int64Value,
                data: .user(UserData(displayName: user.displayName, id: user.id, image: user.image ?? "", username: user.username))
            )
        case .members:
            let members = room.state.members.map {
                UserData(displayName: $0.displayName, id: Int($0.id), image: $0.image, username: $0.username)
            }

            respond(.members, sequence: sequence.int64Value, data: .members(members))
        }
    }

    func close(callback: (() -> Void)? = nil) {
        write(.closed, data: "{}", completion: callback)
        shutdown()
    }

    func shutdown() {
        webView.stopLoading()
        webView.configuration.userContentController.removeAllUserScripts()

        if #available(iOS 14.0, *) {
            webView.configuration.userContentController.removeAllScriptMessageHandlers()
        }
    }

    @objc private func exitTapped() {
        delegate?.didTapCloseMiniView(self)
    }
}

extension MiniView: WKNavigationDelegate {
    func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        loadingIndicator.startAnimating()
    }

    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        loadingIndicator.stopAnimating()
    }
}
