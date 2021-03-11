import UIKit

// @TODO SCROLL VIEW SO WE HAVE PTR

class ViewControllerWithRemoteContent<T: Decodable>: ViewController {
    var content: T!

    private let loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        view.color = .label
        return view
    }()

    let contentView: UIScrollView = {
        let view = UIScrollView()
        view.refreshControl = UIRefreshControl()
        view.refreshControl!.addTarget(self, action: #selector(loadData), for: .valueChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        loadingIndicator.startAnimating()

        contentView.isHidden = true
        view.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.leftAnchor.constraint(equalTo: view.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }

    func didLoad(content: T) {
        contentView.refreshControl?.endRefreshing()
        self.content = content
        loadingIndicator.stopAnimating()
        contentView.isHidden = false
    }

    @objc func loadData() {
        contentView.refreshControl?.beginRefreshing()
    }
}
