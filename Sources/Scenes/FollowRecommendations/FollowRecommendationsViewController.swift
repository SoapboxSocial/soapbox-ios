import UIKit

class FollowRecommendationsViewController: DrawerViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .largeTitle, weight: .heavy)
        label.textColor = .white
        label.text = NSLocalizedString("FollowRecommendations.Title", comment: "")
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .body, weight: .semibold)
        label.text = NSLocalizedString("FollowRecommendations.Description", comment: "")
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    private let collection: UICollectionView = {
        let size = NSCollectionLayoutSize(
            widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
            heightDimension: .estimated(48)
        )
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        section.interGroupSpacing = 20

        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(section: section))
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(cellWithClass: FollowRecommendationsCollectionViewCell.self)
        collection.backgroundColor = .clear
        return collection
    }()

    private var users = [APIClient.User]()

    private var removeUsers = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()

        manager.drawer.backgroundColor = .brandColor

        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: handle.topAnchor, constant: 30),
        ])

        view.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            descriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            descriptionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
        ])

        let seperator = UIView()
        seperator.translatesAutoresizingMaskIntoConstraints = false
        seperator.backgroundColor = .lightBrandColor
        seperator.layer.cornerRadius = 1
        view.addSubview(seperator)

        NSLayoutConstraint.activate([
            seperator.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            seperator.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            seperator.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            seperator.heightAnchor.constraint(equalToConstant: 2),
        ])

        let youMayKnow = UILabel()
        youMayKnow.translatesAutoresizingMaskIntoConstraints = false
        youMayKnow.textColor = .white
        youMayKnow.text = NSLocalizedString("FollowRecommendations.YouMayKnow", comment: "").uppercased()
        youMayKnow.font = .boldSystemFont(ofSize: 17)
        view.addSubview(youMayKnow)

        NSLayoutConstraint.activate([
            youMayKnow.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            youMayKnow.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            youMayKnow.topAnchor.constraint(equalTo: seperator.topAnchor, constant: 20),
        ])

        collection.dataSource = self
        collection.delegate = self
        view.addSubview(collection)

        APIClient().recommendedFollows(callback: { result in
            switch result {
            case .failure:
                break // @todo
            case let .success(users):
                self.users = users
                DispatchQueue.main.async {
                    self.collection.reloadData()
                }
            }
        })

        NSLayoutConstraint.activate([
            collection.leftAnchor.constraint(equalTo: view.leftAnchor),
            collection.rightAnchor.constraint(equalTo: view.rightAnchor),
            collection.topAnchor.constraint(equalTo: youMayKnow.bottomAnchor, constant: 10),
            collection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension FollowRecommendationsViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return users.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: FollowRecommendationsCollectionViewCell.self, for: indexPath)

        let user = users[indexPath.item]

        cell.handler = {
            self.follow(user: user.id)
        }

        cell.image.backgroundColor = .lightBrandColor

        if let image = user.image, image != "" {
            cell.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + image))
        }

        cell.title.textColor = .white
        cell.title.text = user.displayName

        cell.subtitle.textColor = .white
        cell.subtitle.text = "@" + user.username

        return cell
    }

    private func follow(user: Int) {
        APIClient().follow(id: user, callback: { [self] result in
            switch result {
            case .failure:
                let banner = NotificationBanner(
                    title: NSLocalizedString("something_went_wrong", comment: ""),
                    subtitle: NSLocalizedString("please_try_again_later", comment: ""),
                    style: .danger,
                    type: .floating
                )

                DispatchQueue.main.async {
                    banner.show()
                }
            case .success:
                self.remove(user: user)
            }
        })
    }

    private func remove(user: Int) {
        removeUsers.append(user)

        if removeUsers.count == 0 {
            removeUser()
        }
    }

    private func removeUser() {
        guard let user = removeUsers.first else {
            return
        }

        if let item = self.users.firstIndex(where: { $0.id == user }) {
            users.removeAll(where: { $0.id == user })
            DispatchQueue.main.async {
                self.collection.deleteItems(at: [IndexPath(item: item, section: 0)])
            }
        } else {
            users.removeAll(where: { $0.id == user })
            return DispatchQueue.main.async {
                self.collection.reloadData()
            }
        }

        removeUsers.removeFirst()
        removeUser()
    }
}

extension FollowRecommendationsViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = users[indexPath.item]
        guard let parent = presentingViewController as? NavigationViewController else {
            return
        }

        dismiss(animated: true, completion: {
            DispatchQueue.main.async {
                parent.pushViewController(SceneFactory.createProfileViewController(id: user.id), animated: true)
            }
        })
    }
}
