import NotificationBannerSwift
import UIKit

protocol UserListViewControllerOutput {
    func loadUsers()
}

class UserListViewController: ViewController {
    var output: UserListViewControllerOutput!

    private var collection: UICollectionView!
    private var users = [APIClient.User]()

    override func viewDidLoad() {
        view.backgroundColor = .background

        collection = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .clear

        collection.register(cellWithClass: CollectionViewCell.self)
        collection.register(cellWithClass: ViewMoreCellCollectionViewCell.self)
        collection.register(supplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withClass: EmptyCollectionFooterView.self)

        output.loadUsers()

        view.addSubview(collection)

        NSLayoutConstraint.activate([
            collection.leftAnchor.constraint(equalTo: view.leftAnchor),
            collection.rightAnchor.constraint(equalTo: view.rightAnchor),
            collection.topAnchor.constraint(equalTo: view.topAnchor),
            collection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (_: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let section = NSCollectionLayoutSection.fullWidthSection(hasFooter: true)
            section.boundarySupplementaryItems = [self.createSectionFooter(height: 105)]
            return section
        }

        layout.register(CollectionBackgroundView.self, forDecorationViewOfKind: "background")
        layout.configuration = UICollectionViewCompositionalLayoutConfiguration()

        return layout
    }

    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(38)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }

    private func createSectionFooter(height: CGFloat = 58) -> NSCollectionLayoutBoundarySupplementaryItem {
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height)),
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
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
            self.collection.reloadData()
        }
    }
}

extension UserListViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        if users.count == 0 {
            return 0
        }

        if users.count % 10 != 0 {
            return users.count
        }

        return users.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == users.count {
            return collection.dequeueReusableCell(withClass: ViewMoreCellCollectionViewCell.self, for: indexPath)
        }

        let cell = collectionView.dequeueReusableCell(withClass: CollectionViewCell.self, for: indexPath)
        let user = users[indexPath.item]

        cell.title.text = user.displayName
        cell.subtitle.text = "@" + user.username

        if let image = user.image, image != "" {
            cell.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + image))
        }

        return cell
    }
}

extension UserListViewController: UICollectionViewDelegate {
    // @TODO probably needs to be in the interactor?
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == users.count {
            return output.loadUsers()
        }

        navigationController?.pushViewController(SceneFactory.createProfileViewController(id: users[indexPath.item].id), animated: true)
    }
}
