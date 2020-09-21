import AlamofireImage
import UIKit

protocol SearchViewControllerOutput {
    func search(_ keyword: String)
}

class SearchViewController: UIViewController {
    var output: SearchViewControllerOutput!

    private var collection: UICollectionView!
    private var users = [APIClient.User]()

    private let refresh = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        collection = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collection.automaticallyAdjustsScrollIndicatorInsets = false
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .clear
        collection.keyboardDismissMode = .onDrag

        collection.refreshControl = refresh
        refresh.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)

        collection.register(cellWithClass: UserCell.self)

        output.search("*")

        view.addSubview(collection)
    }

    @objc private func didPullToRefresh() {
        refresh.endRefreshing()
    }
}

extension SearchViewController: UICollectionViewDelegate {
    // @TODO probably needs to be in the interactor?
    func collectionView(_: UICollectionView, didSelectItemAt _: IndexPath) {
        view.endEditing(true)
        presentingViewController?.navigationController?.pushViewController(ProfileViewControllerV2(), animated: true)
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
