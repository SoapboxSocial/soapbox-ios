import UIKit

protocol UserListViewControllerOutput {
    func loadUsers()
}

class UserListViewController: ViewControllerWithScrollableContent<UICollectionView> {
    var output: UserListViewControllerOutput!

    private var users = [APIClient.User]()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        content = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        content.translatesAutoresizingMaskIntoConstraints = false
        content.delegate = self
        content.dataSource = self
        content.backgroundColor = .clear

        content.register(cellWithClass: CollectionViewCell.self)
        content.register(cellWithClass: ViewMoreCellCollectionViewCell.self)
        content.register(supplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withClass: EmptyCollectionFooterView.self)

        output.loadUsers()

        view.addSubview(content)

        NSLayoutConstraint.activate([
            content.leftAnchor.constraint(equalTo: view.leftAnchor),
            content.rightAnchor.constraint(equalTo: view.rightAnchor),
            content.topAnchor.constraint(equalTo: view.topAnchor),
            content.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (_: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            self.content.section(hasFooter: true)
        }

        layout.configuration = UICollectionViewCompositionalLayoutConfiguration()

        return layout
    }
}

extension UserListViewController: UserListPresenterOutput {
    func displayError(title: String, description: String?) {
        let banner = NotificationBanner(
            title: title,
            subtitle: description,
            style: .danger,
            type: .floating
        )

        banner.show()

        stopLoader()
    }

    func display(users: [APIClient.User]) {
        if users.isEmpty {
            return stopLoader()
        }

        self.users.append(contentsOf: users)

        DispatchQueue.main.async {
            self.content.reloadData()
        }
    }

    private func stopLoader() {
        if users.count == 0 {
            return
        }

        DispatchQueue.main.async {
            self.content.reloadItems(at: [IndexPath(item: self.users.count, section: 0)])
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
            return collectionView.dequeueReusableCell(withClass: ViewMoreCellCollectionViewCell.self, for: indexPath)
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

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: EmptyCollectionFooterView.self, for: indexPath)
        }

        fatalError("unknown kind: \(kind)")
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
