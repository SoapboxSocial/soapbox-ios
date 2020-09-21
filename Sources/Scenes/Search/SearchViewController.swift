import AlamofireImage
import UIKit

protocol SearchViewControllerOutput {
    func search(_ keyword: String)
}

class SearchViewController: UIViewController {
    var output: SearchViewControllerOutput!

    private var collection: UICollectionView!

    private var users = [APIClient.User]()

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

        collection.register(cellWithClass: UserCellV2.self)

        output.search("*")

        view.addSubview(collection)
    }
}

extension SearchViewController: UICollectionViewDelegate {}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return users.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: UserCellV2.self, for: indexPath)

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
            self.collection.reloadData()
        }
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for _: UISearchController) {}
}

extension SearchViewController: UISearchControllerDelegate {}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_: UISearchBar) {
        view.endEditing(true)
    }
}
