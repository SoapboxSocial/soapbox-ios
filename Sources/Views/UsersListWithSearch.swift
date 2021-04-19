import UIKit

@objc protocol UsersListWithSearchDelegate {
    func usersList(_ list: UsersListWithSearch, didSelect id: Int)
    @objc optional func usersList(_ list: UsersListWithSearch, didDeselect id: Int)
}

class UsersListWithSearch: UIView {
    var delegate: UsersListWithSearchDelegate?

    private var users = [APIClient.User]()

    private var filtered = [APIClient.User]()

    private var list: UICollectionView!

    private(set) var selected = [Int]()

    private var searchBar: TextField!

    private let allowsDeselection: Bool

    var isSearchBarEmpty: Bool {
        return searchBar.text?.isEmpty ?? true
    }

    init(width: CGFloat, allowsDeselection: Bool) {
        self.allowsDeselection = allowsDeselection

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        searchBar = TextField(frame: .zero, theme: .light)
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.addTarget(self, action: #selector(updateSearchResults), for: .editingChanged)
        searchBar.backgroundColor = .lightBrandColor
        searchBar.clearButtonMode = .whileEditing
        searchBar.returnKeyType = .done
        searchBar.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("search", comment: ""),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        addSubview(searchBar)

        let layout = UICollectionViewFlowLayout.basicUserBubbleLayout(itemsPerRow: 4, width: width)
        layout.sectionInset.bottom = safeAreaInsets.bottom

        list = UICollectionView(frame: .zero, collectionViewLayout: layout)
        list!.dataSource = self
        list!.delegate = self
        list!.allowsMultipleSelection = true
        list!.translatesAutoresizingMaskIntoConstraints = false
        list!.register(cellWithClass: SelectableImageTextCell.self)
        list!.backgroundColor = .clear
        addSubview(list)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            searchBar.leftAnchor.constraint(equalTo: leftAnchor),
            searchBar.rightAnchor.constraint(equalTo: rightAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 48),
        ])

        NSLayoutConstraint.activate([
            list.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 30),
            list.leftAnchor.constraint(equalTo: leftAnchor),
            list.rightAnchor.constraint(equalTo: rightAnchor),
            list.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(users: [APIClient.User]) {
        self.users = users

        DispatchQueue.main.async {
            self.list.reloadData()
        }
    }
}

extension UsersListWithSearch: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item = collectionView.cellForItem(at: indexPath)
        if item?.isSelected ?? false {
            return false
        }

        return true
    }

    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        if !allowsDeselection {
            return false
        }

        let item = collectionView.cellForItem(at: indexPath)
        if item?.isSelected ?? false {
            return true
        }

        return false
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SelectableImageTextCell else {
            return
        }

        let user = getUser(for: indexPath)

        cell.selectedView.isHidden = false

        selected.append(user.id)
        delegate?.usersList(self, didSelect: user.id)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SelectableImageTextCell else {
            return
        }

        let user = getUser(for: indexPath)

        cell.selectedView.isHidden = true

        selected.removeAll(where: { $0 == user.id })
        delegate?.usersList?(self, didDeselect: user.id)
    }
}

extension UsersListWithSearch: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        if isSearchBarEmpty {
            return users.count
        }

        return filtered.count
    }

    func collectionView(_: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = list.dequeueReusableCell(withClass: SelectableImageTextCell.self, for: indexPath)

        let user = getUser(for: indexPath)

        cell.image.backgroundColor = .lightBrandColor
        if let image = user.image, image != "" {
            cell.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + image))
        }

        cell.title.text = user.displayName.firstName()
        cell.title.textColor = .white

        if selected.contains(user.id) {
            cell.selectedView.isHidden = false
        } else {
            cell.selectedView.isHidden = true
        }

        return cell
    }

    private func getUser(for indexPath: IndexPath) -> APIClient.User {
        if isSearchBarEmpty {
            return users[indexPath.row]
        }

        return filtered[indexPath.row]
    }
}

extension UsersListWithSearch: UITextFieldDelegate {
    @objc private func updateSearchResults() {
        guard let text = searchBar.text else {
            return
        }

        filter(text)
    }

    func filter(_ searchText: String) {
        filtered = users.filter {
            $0.displayName.lowercased().contains(searchText.lowercased()) || $0.username.lowercased().contains(searchText.lowercased())
        }

        list.reloadData()
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        endEditing(true)
        return true
    }
}
