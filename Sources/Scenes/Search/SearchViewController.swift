import AlamofireImage
import UIKit

protocol SearchViewControllerOutput {
    func search(_ keyword: String)
    func loadMore(type: APIClient.SearchIndex)
}

class SearchViewController: ViewControllerWithScrollableContent<UICollectionView> {
    var output: SearchViewControllerOutput!

    private let presenter = SearchCollectionPresenter()

    override func loadView() {
        super.loadView()

        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.setSearchFieldBackgroundImage(UIImage(), for: .normal)

        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController

        setupSearchBar()
    }

    private func setupSearchBar() {
        let searchField = navigationItem.searchController!.searchBar.value(forKey: "searchField") as? UITextField

        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [
            NSAttributedString.Key.font: UIFont.rounded(forTextStyle: .title3, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.label,
        ]

        guard let field = searchField else {
            return
        }

        field.layer.cornerRadius = 15.0
        field.backgroundColor = .foreground

        field.layer.masksToBounds = true
        field.returnKeyType = .search

        field.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("search_placeholder", comment: ""),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel]
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background
        title = NSLocalizedString("search", comment: "")

        content = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        content.translatesAutoresizingMaskIntoConstraints = false
        content.delegate = self
        content.dataSource = self
        content.backgroundColor = .clear
        content.keyboardDismissMode = .onDrag

        presenter.appendInviteFriendsSection()

        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(endRefresh), for: .valueChanged)
        content.refreshControl = refresh

        content.register(cellWithClass: CollectionViewCell.self)
        content.register(cellWithClass: InviteFriendsCell.self)
        content.register(cellWithClass: ViewMoreCellCollectionViewCell.self)
        content.register(supplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: CollectionViewSectionTitle.self)
        content.register(supplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withClass: EmptyCollectionFooterView.self)

        output.search("*")

        view.addSubview(content)

        NSLayoutConstraint.activate([
            content.leftAnchor.constraint(equalTo: view.leftAnchor),
            content.rightAnchor.constraint(equalTo: view.rightAnchor),
            content.topAnchor.constraint(equalTo: view.topAnchor),
            content.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupSearchBar()
    }

    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            switch self.presenter.sectionType(for: sectionIndex) {
            case .userList:
                return self.content.section(hasHeader: true, hasFooter: true)
            case .inviteFriends:
                return self.content.section(height: 182, hasBackground: false)
            }
        }

        layout.register(CollectionBackgroundView.self, forDecorationViewOfKind: "background")
        layout.configuration = UICollectionViewCompositionalLayoutConfiguration()

        return layout
    }

    @objc private func endRefresh() {
        content.refreshControl?.endRefreshing()
    }
}

extension SearchViewController: UICollectionViewDelegate {
    // @TODO probably needs to be in the interactor?
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view.endEditing(true)

        switch presenter.sectionType(for: indexPath.section) {
        case .userList:
            if (indexPath.item + 1) == presenter.numberOfItems(for: indexPath.section) {
                return output.loadMore(type: .users)
            }

            let user = presenter.item(for: IndexPath(item: indexPath.item, section: indexPath.section), ofType: APIClient.User.self)
            navigationController?.pushViewController(SceneFactory.createProfileViewController(id: user.id), animated: true)
        case .inviteFriends:
            return
        }
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        return presenter.numberOfSections
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection index: Int) -> Int {
        return presenter.numberOfItems(for: index)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch presenter.sectionType(for: indexPath.section) {
        case .userList:
            if (indexPath.item + 1) == presenter.numberOfItems(for: indexPath.section) {
                return collectionView.dequeueReusableCell(withClass: ViewMoreCellCollectionViewCell.self, for: indexPath)
            }

            let cell = collectionView.dequeueReusableCell(withClass: CollectionViewCell.self, for: indexPath)
            presenter.configure(item: cell, forUser: indexPath)
            return cell
        case .inviteFriends:
            return collectionView.dequeueReusableCell(withClass: InviteFriendsCell.self, for: indexPath)
        }
    }

    func collectionView(_: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            return content.dequeueReusableSupplementaryView(ofKind: kind, withClass: EmptyCollectionFooterView.self, for: indexPath)
        case UICollectionView.elementKindSectionHeader:
            let cell = content.dequeueReusableSupplementaryView(ofKind: kind, withClass: CollectionViewSectionTitle.self, for: indexPath)
            cell.label.font = .rounded(forTextStyle: .title2, weight: .bold)
            cell.label.text = presenter.sectionTitle(for: indexPath.section)
            return cell
        default:
            fatalError("unknown kind: \(kind)")
        }
    }
}

extension SearchViewController: SearchPresenterOutput {
    func display(users: [APIClient.User]) {
        presenter.set(users: users)

        DispatchQueue.main.async {
            self.content.refreshControl?.endRefreshing()
            self.content.reloadData()
        }
    }

    func displayMore(users: [APIClient.User]) {
        if users.isEmpty {
            return stopLoader(for: .userList)
        }

        presenter.append(users: users)

        guard let index = presenter.index(of: .userList) else {
            return
        }

        DispatchQueue.main.async {
            self.content.reloadSections(IndexSet(integer: index))
        }
    }

    func displaySearchError() {
        content.refreshControl?.endRefreshing()
        stopLoader(for: .userList)
    }

    private func stopLoader(for section: SearchCollectionPresenter.SectionType) {
        guard let index = presenter.index(of: section) else {
            return
        }

        let items = presenter.numberOfItems(for: index)
        if items == 0 {
            return
        }

        DispatchQueue.main.async {
            self.content.reloadItems(at: [IndexPath(item: items - 1, section: index)])
        }
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        var text = "*"
        if let input = searchController.searchBar.text, input != "" {
            text = input
            presenter.removeInviteFriendsSection()
        }

        content.refreshControl?.beginRefreshing()
        output.search(text)
    }
}
