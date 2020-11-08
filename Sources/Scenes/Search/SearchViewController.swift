import AlamofireImage
import CCBottomRefreshControl
import NotificationBannerSwift
import UIKit

protocol SearchViewControllerOutput {
    func search(_ keyword: String)
    func nextPage()
}

class SearchViewController: UIViewController {
    var output: SearchViewControllerOutput!

    private var collection: UICollectionView!
    private var users = [APIClient.User]()

    private let paginate = UIRefreshControl()

    private var searchBar: TextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background
        title = NSLocalizedString("search", comment: "")

        let layout = UICollectionViewFlowLayout.usersLayout()
        layout.sectionInset.top = 0

        collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .clear
        collection.keyboardDismissMode = .onDrag

        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(endRefresh), for: .valueChanged)
        collection.refreshControl = refresh

        collection.register(cellWithClass: UserCell.self)

        output.search("*")

        view.addSubview(collection)

        paginate.addTarget(self, action: #selector(loadMore), for: .valueChanged)
        paginate.triggerVerticalOffset = 100
        collection.bottomRefreshControl = paginate

        searchBar = TextField(frame: .zero, theme: .normal)
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.addTarget(self, action: #selector(updateSearchResults), for: .editingChanged)
        searchBar.clearButtonMode = .whileEditing
        searchBar.returnKeyType = .done
        searchBar.placeholder = NSLocalizedString("search_for_friends", comment: "")
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.topAnchor),
            searchBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            searchBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            searchBar.heightAnchor.constraint(equalToConstant: 48),
        ])

        NSLayoutConstraint.activate([
            collection.leftAnchor.constraint(equalTo: view.leftAnchor),
            collection.rightAnchor.constraint(equalTo: view.rightAnchor),
            collection.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            collection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    @objc private func endRefresh() {
        collection.refreshControl?.endRefreshing()
    }

    @objc private func loadMore() {
        output.nextPage()
    }
}

extension SearchViewController: UICollectionViewDelegate {
    // @TODO probably needs to be in the interactor?
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view.endEditing(true)

        let id = users[indexPath.item].id
        navigationController?.pushViewController(SceneFactory.createProfileViewController(id: id), animated: true)
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return users.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: UserCell.self, for: indexPath)
        cell.layer.mask = nil
        cell.layer.cornerRadius = 0

        if indexPath.item == 0 {
            cell.roundCorners(corners: [.topLeft, .topRight], radius: 30)
        }

        if indexPath.item == (users.count - 1) {
            cell.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 30)
        }

        if indexPath.item == 0, users.count == 1 {
            cell.layer.mask = nil
            cell.layer.cornerRadius = 30
            cell.layer.masksToBounds = true
        }

        let user = users[indexPath.item]

        cell.displayName.text = user.displayName
        cell.username.text = "@" + user.username

        cell.image.image = nil
        if let image = user.image, image != "" {
            cell.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + image))
        }

        return cell
    }
}

extension SearchViewController: SearchPresenterOutput {
    func display(users: [APIClient.User]) {
        self.users = users

        DispatchQueue.main.async {
            self.collection.refreshControl?.endRefreshing()
            self.collection.reloadData()
        }
    }

    func display(nextPage users: [APIClient.User]) {
        DispatchQueue.main.async {
            self.collection.bottomRefreshControl?.endRefreshing()

            self.users.append(contentsOf: users)
            self.collection.reloadData()
        }
    }

    func displaySearchError() {
        collection.refreshControl?.endRefreshing()
        collection.bottomRefreshControl?.endRefreshing()
    }
}

extension SearchViewController: UITextFieldDelegate {
    @objc private func updateSearchResults() {
        var text = "*"
        if let input = searchBar.text, input != "" {
            text = input
        }

        collection.refreshControl?.beginRefreshing()
        output.search(text)
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
