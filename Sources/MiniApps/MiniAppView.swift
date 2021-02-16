import UIKit
import WebKit

class MiniAppView: UIView {
    enum Query: String, CaseIterable {
        case room, user, members
    }

    enum Response: String {
        case room, user, members
    }

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

    init(app _: String) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

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

        webView.load(URLRequest(url: URL(string: "")!))
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // @TODO
    private func respond(type: Response, msg: String) {
        webView.evaluateJavaScript(type.rawValue, completionHandler: { result, error in
            if result != nil { // @TODO
                return
            }

            if error != nil {
                // @TODO
            }
        })
    }
}

// @TODO WE NEED ACCESS CONTROL FOR THIS, WE NEED TO FIGURE OUT HOW ONLY THE ROOM KING OR WHATEVER SHOULD RESPOND
extension MiniAppView: WKScriptMessageHandler {
    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let event = Query(rawValue: message.name) else {
            return
        }

        switch event {
        case .room:
            return
        case .user:
            return
        case .members:
            return
        }
    }
}
