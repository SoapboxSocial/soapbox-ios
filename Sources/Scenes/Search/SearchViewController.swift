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

    private var searchController = UISearchController()

    private let paginate = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.usersLayout())
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

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.showsSearchResultsController = true
        searchController.automaticallyShowsCancelButton = false

        let scb = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        scb.returnKeyType = .default
        scb.delegate = self
        scb.showsCancelButton = false
        scb.placeholder = NSLocalizedString("search_for_friends", comment: "")
        scb.searchTextField.layer.masksToBounds = true
        scb.searchTextField.layer.cornerRadius = 15
        scb.searchTextField.leftView = nil

        title = NSLocalizedString("search", comment: "")

        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false

        navigationItem.searchController = searchController

        NSLayoutConstraint.activate([
            collection.leftAnchor.constraint(equalTo: view.leftAnchor),
            collection.rightAnchor.constraint(equalTo: view.rightAnchor),
            collection.topAnchor.constraint(equalTo: view.topAnchor),
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

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        var text = "*"
        if let input = searchController.searchBar.text, input != "" {
            text = input
        }

        collection.refreshControl?.beginRefreshing()
        output.search(text)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_: UISearchBar) {
        view.endEditing(true)
    }
}
