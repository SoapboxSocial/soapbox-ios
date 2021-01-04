import CCBottomRefreshControl
import NotificationBannerSwift
import UIKit

protocol UserListViewControllerOutput {
    func loadUsers()
}

class UserListViewController: ViewController {
    var output: UserListViewControllerOutput!

    private var collection: UICollectionView!
    private var users = [APIClient.User]()

    private let paginate = UIRefreshControl()

    override func viewDidLoad() {
        view.backgroundColor = .background

        let layout = UICollectionViewFlowLayout.usersLayout()

        collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .clear

        collection.register(cellWithClass: UserCell.self)

        output.loadUsers()

        view.addSubview(collection)

        paginate.addTarget(self, action: #selector(loadMore), for: .valueChanged)
        paginate.triggerVerticalOffset = 100
        collection.bottomRefreshControl = paginate

        NSLayoutConstraint.activate([
            collection.leftAnchor.constraint(equalTo: view.leftAnchor),
            collection.rightAnchor.constraint(equalTo: view.rightAnchor),
            collection.topAnchor.constraint(equalTo: view.topAnchor),
            collection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    @objc private func loadMore() {
        output.loadUsers()
    }
}

extension UserListViewController: UserListPresenterOutput {
    func displayError(title: String, description: String?) {
        let banner = FloatingNotificationBanner(
            title: title,
            subtitle: description,
            style: .danger
        )

        banner.show(cornerRadius: 10, shadowBlurRadius: 15)
    }

    func display(users: [APIClient.User]) {
        self.users.append(contentsOf: users)

        DispatchQueue.main.async {
            self.collection.bottomRefreshControl?.endRefreshing()
            self.collection.reloadData()
        }
    }
}

extension UserListViewController: UICollectionViewDataSource {
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

        if let image = user.image, image != "" {
            cell.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + image))
        }

        return cell
    }
}

extension UserListViewController: UICollectionViewDelegate {
    // @TODO probably needs to be in the interactor?
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.pushViewController(SceneFactory.createProfileViewController(id: users[indexPath.item].id), animated: true)
    }
}
