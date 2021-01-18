import UIKit
import WebKit

class WebPageViewController: UIViewController {
    private let url: URL

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
//        tempWebView.uiDelegate = self
//        tempWebView.navigationDelegate = self
        return webView
    }()

    init(url: URL) {
        self.url = url
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

extension WebPageViewController: WKNavigationDelegate {
    func webView(_: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        debugPrint(navigation)
    }
}
