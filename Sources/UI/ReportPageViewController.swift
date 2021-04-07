import UIKit
import WebKit

class ReportPageViewController: UIViewController {
    private var url = URL(string: "https://soapbox.social/report/incident")!

    private let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.isTranslucent = true
        toolbar.tintColor = .brandColor
        return toolbar
    }()

    private var webView: WKWebView = {
        var webView = WKWebView(frame: .zero)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    private let userId: Int
    private let reportedUserId: Int?

    init(userId: Int, reportedUserId: Int? = nil) {
        self.userId = userId
        self.reportedUserId = reportedUserId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(toolbar)

        NSLayoutConstraint.activate([
            toolbar.leftAnchor.constraint(equalTo: view.leftAnchor),
            toolbar.rightAnchor.constraint(equalTo: view.rightAnchor),
            toolbar.topAnchor.constraint(equalTo: view.topAnchor),
        ])

        let doneItem = UIBarButtonItem(title: NSLocalizedString("done", comment: ""), style: .done, target: self, action: #selector(donePressed))
        toolbar.items = [doneItem]

        view.backgroundColor = .background

        url.appendQueryParameters(["userId": String(userId)])

        if let reportedUser = reportedUserId {
            url.appendQueryParameters(["reportedUserId": String(reportedUser)])
        }

        webView.load(URLRequest(url: url))
        webView.navigationDelegate = self

        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
        ])
    }

    @objc private func donePressed() {
        dismiss(animated: true)
    }
}

extension ReportPageViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        if webView.url!.absoluteString.range(of: "/report/received") != nil {
            dismiss(animated: true)
        }
    }
}
