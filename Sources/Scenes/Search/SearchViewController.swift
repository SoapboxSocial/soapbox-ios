import AlamofireImage
import UIKit

protocol SearchViewControllerOutput {
    func search(_ keyword: String)
    func loadMore(type: APIClient.SearchIndex)
}

class SearchViewController: ViewController {
    var output: SearchViewControllerOutput!

    private var collection: UICollectionView!

    private var searchBar: TextField!

    private let presenter = SearchCollectionPresenter()
    
    override func loadView() {
        super.loadView()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        
        navigationController?.navigationItem.searchController = searchController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background
        title = NSLocalizedString("search", comment: "")

        collection = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .clear
        collection.keyboardDismissMode = .onDrag

        presenter.appendInviteFriendsSection()

        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(endRefresh), for: .valueChanged)
        collection.refreshControl = refresh

        collection.register(cellWithClass: CollectionViewCell.self)
        collection.register(cellWithClass: InviteFriendsCell.self)
        collection.register(cellWithClass: ViewMoreCellCollectionViewCell.self)
        collection.register(supplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: CollectionViewSectionTitle.self)
        collection.register(supplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withClass: EmptyCollectionFooterView.self)

        output.search("*")

        view.addSubview(collection)

        searchBar = TextField(frame: .zero, theme: .normal)
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.addTarget(self, action: #selector(updateSearchResults), for: .editingChanged)
        searchBar.clearButtonMode = .whileEditing
        searchBar.returnKeyType = .done
        searchBar.placeholder = NSLocalizedString("search_placeholder", comment: "")
//        view.addSubview(searchBar)

//        NSLayoutConstraint.activate([
//            searchBar.topAnchor.constraint(equalTo: view.topAnchor),
//            searchBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
//            searchBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
//            searchBar.heightAnchor.constraint(equalToConstant: 48),
//        ])

        NSLayoutConstraint.activate([
            collection.leftAnchor.constraint(equalTo: view.leftAnchor),
            collection.rightAnchor.constraint(equalTo: view.rightAnchor),
            collection.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            collection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            switch self.presenter.sectionType(for: sectionIndex) {
            case .groupList:
                return self.collection.section(hasHeader: true, hasFooter: true)
            case .userList:
                return self.collection.section(hasHeader: true, hasFooter: self.presenter.index(of: .groupList) == nil)
            case .inviteFriends:
                return self.collection.section(height: 182, hasBackground: false)
            }
        }

        layout.register(CollectionBackgroundView.self, forDecorationViewOfKind: "background")
        layout.configuration = UICollectionViewCompositionalLayoutConfiguration()

        return layout
    }

    @objc private func endRefresh() {
        collection.refreshControl?.endRefreshing()
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
        case .groupList:
            if (indexPath.item + 1) == presenter.numberOfItems(for: indexPath.section) {
                return output.loadMore(type: .groups)
            }

            let group = presenter.item(for: IndexPath(item: indexPath.item, section: indexPath.section), ofType: APIClient.Group.self)
            navigationController?.pushViewController(SceneFactory.createGroupViewController(id: group.id), animated: true)
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
        case .groupList:
            if (indexPath.item + 1) == presenter.numberOfItems(for: indexPath.section) {
                return collectionView.dequeueReusableCell(withClass: ViewMoreCellCollectionViewCell.self, for: indexPath)
            }

            let cell = collectionView.dequeueReusableCell(withClass: CollectionViewCell.self, for: indexPath)
            presenter.configure(item: cell, forGroup: indexPath)
            return cell
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
            return collection.dequeueReusableSupplementaryView(ofKind: kind, withClass: EmptyCollectionFooterView.self, for: indexPath)
        case UICollectionView.elementKindSectionHeader:
            let cell = collection.dequeueReusableSupplementaryView(ofKind: kind, withClass: CollectionViewSectionTitle.self, for: indexPath)
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
            self.collection.refreshControl?.endRefreshing()
            self.collection.reloadData()
        }
    }

    func display(groups: [APIClient.Group]) {
        presenter.set(groups: groups)

        DispatchQueue.main.async {
            self.collection.refreshControl?.endRefreshing()
            self.collection.reloadData()
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
            self.collection.reloadSections(IndexSet(integer: index))
        }
    }

    func displayMore(groups: [APIClient.Group]) {
        if groups.isEmpty {
            return stopLoader(for: .groupList)
        }

        presenter.append(groups: groups)

        guard let index = presenter.index(of: .groupList) else {
            return
        }

        DispatchQueue.main.async {
            self.collection.reloadSections(IndexSet(integer: index))
        }
    }

    func displaySearchError() {
        collection.refreshControl?.endRefreshing()
        stopLoader(for: .userList)
        stopLoader(for: .groupList)
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
            self.collection.reloadItems(at: [IndexPath(item: items - 1, section: index)])
        }
    }
}

extension SearchViewController: UITextFieldDelegate {
    @objc private func updateSearchResults() {
        var text = "*"
        if let input = searchBar.text, input != "" {
            text = input
            presenter.removeInviteFriendsSection()
        }

        collection.refreshControl?.beginRefreshing()
        output.search(text)
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
