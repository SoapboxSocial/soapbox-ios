import AlamofireImage
import CCBottomRefreshControl
import NotificationBannerSwift
import UIKit

protocol SearchResultsViewControllerOutput {
    func search()
    func nextPage()
}

class SearchResultsViewController: ViewController {
    var output: SearchResultsViewControllerOutput!

    var type: APIClient.SearchIndex!

    private var collection: UICollectionView!

    private var users = [APIClient.User]()
    private var groups = [APIClient.Group]()

    private let paginate = UIRefreshControl()

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
        collection.register(cellWithClass: GroupSearchCell.self)

        view.addSubview(collection)

        paginate.addTarget(self, action: #selector(loadMore), for: .valueChanged)
        paginate.triggerVerticalOffset = 100
        collection.bottomRefreshControl = paginate

        output.search()

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

extension SearchResultsViewController: UICollectionViewDelegate {
    // @TODO probably needs to be in the interactor?
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view.endEditing(true)

        switch type {
        case .users:
            let user = users[indexPath.item]
            navigationController?.pushViewController(SceneFactory.createProfileViewController(id: user.id), animated: true)
        case .groups:
            let group = groups[indexPath.item]
            navigationController?.pushViewController(SceneFactory.createGroupViewController(id: group.id), animated: true)
        case .none:
            return
        }
    }
}

extension SearchResultsViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        switch type {
        case .groups:
            return groups.count
        case .users:
            return users.count
        case .none:
            return 0
        }
    }

    func collectionView(_: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        var count = 0

        switch type {
        case .groups:
            count = groups.count
            let group = groups[indexPath.item]

            let groupCell = collection.dequeueReusableCell(withClass: GroupSearchCell.self, for: indexPath)

            groupCell.name.text = group.name

            groupCell.image.image = nil
            if let image = group.image, image != "" {
                groupCell.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + image))
            }

            cell = groupCell
        case .users:
            count = users.count

            let userCell = collection.dequeueReusableCell(withClass: UserCell.self, for: indexPath)

            let user = users[indexPath.item]

            userCell.displayName.text = user.displayName
            userCell.username.text = "@" + user.username

            userCell.image.image = nil
            if let image = user.image, image != "" {
                userCell.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + image))
            }

            cell = userCell
        case .none:
            fatalError()
        }

        cell.layer.mask = nil
        cell.layer.cornerRadius = 0

        if indexPath.item == 0 {
            cell.roundCorners(corners: [.topLeft, .topRight], radius: 30)
        }

        if indexPath.item == (count - 1) {
            cell.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 30)
        }

        if indexPath.item == 0, count == 1 {
            cell.layer.mask = nil
            cell.layer.cornerRadius = 30
            cell.layer.masksToBounds = true
        }

        return cell
    }
}

extension SearchResultsViewController: SearchResultsPresenterOutput {
    func display(groups: [APIClient.Group]) {
        self.groups = groups

        DispatchQueue.main.async {
            self.collection.refreshControl?.endRefreshing()
            self.collection.reloadData()
        }
    }

    func display(nextPageGroups: [APIClient.Group]) {
        DispatchQueue.main.async {
            self.collection.bottomRefreshControl?.endRefreshing()

            self.groups.append(contentsOf: nextPageGroups)
            self.collection.reloadData()
        }
    }

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
