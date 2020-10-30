import AlamofireImage
import UIKit

protocol InviteFriendsListViewControllerOutput {
    func fetchFriends()
    func didSelect(user: Int)
}

class InviteFriendsListViewController: UIViewController {
    var output: InviteFriendsListViewControllerOutput!

    private var friends = [APIClient.User]()

    private var filteredFriends = [APIClient.User]()

    private var friendsList: UICollectionView!
    private let iconConfig = UIImage.SymbolConfiguration(weight: .medium)

    private var invited = [Int]()

    private var searchBar: TextField!

    var isSearchBarEmpty: Bool {
        return searchBar.text?.isEmpty ?? true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .brandColor

        let closeButton = UIButton()
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.titleLabel?.font = .rounded(forTextStyle: .body, weight: .medium)
        closeButton.setTitle(NSLocalizedString("close", comment: ""), for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(closeButton)

        let title = UILabel()
        title.font = .rounded(forTextStyle: .largeTitle, weight: .heavy)
        title.text = NSLocalizedString("invite_your_friends", comment: "")
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = .white
        view.addSubview(title)

        searchBar = TextField(frame: CGRect.zero, theme: .light)
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.addTarget(self, action: #selector(updateSearchResults), for: .editingChanged)
        searchBar.backgroundColor = .lightBrandColor
        searchBar.clearButtonMode = .whileEditing
        searchBar.textColor = .white
        searchBar.tintColor = .white
        searchBar.returnKeyType = .done
        searchBar.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("search", comment: ""),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        view.addSubview(searchBar)

        let layout = UICollectionViewFlowLayout.basicUserBubbleLayout(itemsPerRow: 4, width: view.frame.size.width)
        layout.sectionInset.bottom = view.safeAreaInsets.bottom

        friendsList = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        friendsList!.dataSource = self
        friendsList!.delegate = self
        friendsList!.allowsMultipleSelection = true
        friendsList!.translatesAutoresizingMaskIntoConstraints = false
        friendsList!.register(cellWithClass: SelectableImageTextCell.self)
        friendsList!.backgroundColor = .clear
        view.addSubview(friendsList)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            closeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 20),
            title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            title.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20),
            searchBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            searchBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            searchBar.heightAnchor.constraint(equalToConstant: 48),
        ])

        NSLayoutConstraint.activate([
            friendsList.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 30),
            friendsList.leftAnchor.constraint(equalTo: view.leftAnchor),
            friendsList.rightAnchor.constraint(equalTo: view.rightAnchor),
            friendsList.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        output.fetchFriends()
    }

    @objc private func close() {
        dismiss(animated: true)
    }
}

extension InviteFriendsListViewController: InviteFriendsListPresenterOutput {
    func present(users: [APIClient.User]) {
        friends = users

        DispatchQueue.main.async {
            self.friendsList.reloadData()
        }
    }
}

extension InviteFriendsListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SelectableImageTextCell else {
            return
        }

        let user = getUser(for: indexPath)

        cell.selectedView.isHidden = false

        output.didSelect(user: user.id)
        invited.append(user.id)
    }
}

extension InviteFriendsListViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        if isSearchBarEmpty {
            return friends.count
        }

        return filteredFriends.count
    }

    func collectionView(_: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = friendsList.dequeueReusableCell(withClass: SelectableImageTextCell.self, for: indexPath)

        let user = getUser(for: indexPath)

        cell.image.image = nil
        cell.image.backgroundColor = .lightBrandColor
        if let image = user.image, image != "" {
            cell.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + image))
        }

        cell.title.text = user.displayName.firstName()
        cell.title.textColor = .white

        if invited.contains(user.id) {
            cell.selectedView.isHidden = false
        } else {
            cell.selectedView.isHidden = true
        }

        return cell
    }

    private func getUser(for indexPath: IndexPath) -> APIClient.User {
        if isSearchBarEmpty {
            return friends[indexPath.row]
        }

        return filteredFriends[indexPath.row]
    }
}

extension InviteFriendsListViewController: UITextFieldDelegate {
    @objc private func updateSearchResults() {
        guard let text = searchBar.text else {
            return
        }

        filter(text)
    }

    func filter(_ searchText: String) {
        filteredFriends = friends.filter {
            $0.displayName.lowercased().contains(searchText.lowercased()) || $0.username.lowercased().contains(searchText.lowercased())
        }

        friendsList.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
