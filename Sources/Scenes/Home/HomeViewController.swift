import AlamofireImage
import NotificationBannerSwift
import UIKit

protocol HomeViewControllerOutput {
    func fetchData()
    func didSelectRoom(room: Int)
    func fetchMe()
    func fetchMoreGroups()
}

class HomeViewController: ViewController {
    private let refresh = UIRefreshControl()
    private let downloader = ImageDownloader()

    private var collection: CollectionView!
    private var rooms = [RoomState]()
    private let presenter = HomeCollectionPresenter()

    private var profileImageView: UIImageView!

    var output: HomeViewControllerOutput!

    private var updateQueue = [Update]()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        collection = CollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collection.delegate = self
        collection.dataSource = self
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear

        collection.register(supplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: CollectionViewSectionTitle.self)
        collection.register(cellWithClass: EmptyRoomCollectionViewCell.self)
        collection.register(cellWithClass: RoomCell.self)
        collection.register(cellWithClass: ActiveUserCell.self)
        collection.register(cellWithClass: GroupCell.self)

        collection.refreshControl = refresh
        refresh.addTarget(self, action: #selector(loadData), for: .valueChanged)

        view.addSubview(collection)

        let containView = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        containView.backgroundColor = .brandColor
        containView.layer.cornerRadius = 40 / 2
        containView.clipsToBounds = true
        containView.addTarget(self, action: #selector(openProfile), for: .touchUpInside)

        let barButtonItem = UIBarButtonItem(customView: containView)

        let iconConfig = UIImage.SymbolConfiguration(weight: .bold)

        let searchButton = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass", withConfiguration: iconConfig),
            style: .plain,
            target: self,
            action: #selector(openSearch)
        )

        navigationItem.leftBarButtonItems = [barButtonItem, searchButton]

        profileImageView = UIImageView(frame: containView.frame)
        profileImageView.layer.cornerRadius = containView.frame.size.height / 2
        profileImageView.backgroundColor = .brandColor
        profileImageView.clipsToBounds = true
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        containView.addSubview(profileImageView!)

        let share = UIBarButtonItem(
            image: UIImage(systemName: "arrowshape.turn.up.right", withConfiguration: iconConfig),
            style: .plain,
            target: self,
            action: #selector(shareApp)
        )

        let notificationsButton = UIBarButtonItem(
            image: UIImage(systemName: "bell", withConfiguration: iconConfig),
            style: .plain,
            target: self,
            action: #selector(openNotifications)
        )
        navigationItem.rightBarButtonItems = [share, notificationsButton]

        NSLayoutConstraint.activate([
            collection.leftAnchor.constraint(equalTo: view.leftAnchor),
            collection.rightAnchor.constraint(equalTo: view.rightAnchor),
            collection.topAnchor.constraint(equalTo: view.topAnchor),
            collection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // @TODO probably not best to do this all the time?
        output.fetchMe()
        loadData()
    }

    // @todo this needs to be in the interactor
    @objc private func openProfile() {
        let id = UserDefaults.standard.integer(forKey: "id")
        if id == 0 {
            return (UIApplication.shared.delegate as! AppDelegate).transitionToLoginView()
        }

        let profile = SceneFactory.createProfileViewController(id: id)
        navigationController?.pushViewController(profile, animated: true)
    }

    @objc private func openSearch() {
        let search = SceneFactory.createSearchViewController()
        navigationController?.pushViewController(search, animated: true)
    }

    @objc private func openNotifications() {
        let notifications = SceneFactory.createNotificationsViewController()
        navigationController?.pushViewController(notifications, animated: true)
    }

    @objc private func shareApp() {
        let items: [Any] = [
            NSLocalizedString("share_text", comment: ""),
            URL(string: "https://apps.apple.com/us/app/soapbox-talk-with-anyone/id1529283270")!,
        ]

        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        ac.excludedActivityTypes = [.markupAsPDF, .openInIBooks, .addToReadingList]
        present(ac, animated: true)
    }

    @objc private func loadData() {
        refresh.beginRefreshing()
        output.fetchData()
    }

    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            switch self.presenter.sectionType(for: sectionIndex) {
            case .activeList:
                return self.createActiveListSection()
            case .roomList:
                return self.createRoomListSection()
            case .noRooms:
                return self.createNoRoomsSection()
            case .groupList:
                return self.createGroupSection()
            }
        }

        layout.configuration = UICollectionViewCompositionalLayoutConfiguration()
        layout.configuration.interSectionSpacing = 20
        return layout
    }

    private func createNoRoomsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)

        layoutItem.contentInsets = .zero

        var height = NSCollectionLayoutDimension.fractionalHeight(0.9)

        var heightAbsolute = view.frame.size.height
        if presenter.has(section: .activeList) {
            heightAbsolute -= 300
        }

        if presenter.has(section: .groupList) {
            heightAbsolute -= 200
        }

        if heightAbsolute != view.frame.size.height {
            height = .absolute(heightAbsolute)
        }

        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: height)
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize, subitem: layoutItem, count: 1)

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        return layoutSection
    }

    private func createActiveListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)

        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .absolute(64), heightDimension: .absolute(90))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitem: layoutItem, count: 1)

        layoutGroup.interItemSpacing = .fixed(10)

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.interGroupSpacing = 10
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary

        return layoutSection
    }

    private func createRoomListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(138))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)

        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(138))
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize, subitems: [layoutItem])

        layoutGroup.contentInsets = .zero

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        layoutSection.interGroupSpacing = 20

        layoutSection.boundarySupplementaryItems = [createSectionHeader(), createSectionFooter()]

        return layoutSection
    }

    private func createGroupSection() -> NSCollectionLayoutSection {
        let estimatedWidth = view.frame.size.width * 0.7
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(estimatedWidth), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)

        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .estimated(estimatedWidth), heightDimension: .absolute(56))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])

        layoutGroup.interItemSpacing = .fixed(10)

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.interGroupSpacing = 10
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        layoutSection.orthogonalScrollingBehavior = .continuous

        if presenter.has(section: .activeList) {
            layoutSection.boundarySupplementaryItems = [createSectionHeader()]
        }

        return layoutSection
    }

    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(80)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }

    private func createSectionFooter() -> NSCollectionLayoutBoundarySupplementaryItem {
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(105)),
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
    }
}

extension HomeViewController: HomePresenterOutput {
    func didFetchMoreGroups(groups: [APIClient.Group]) {
        if groups.isEmpty {
            return
        }

        guard let index = presenter.index(of: .groupList) else {
            return
        }

        let count = presenter.numberOfItems(for: index)
        presenter.add(groups: groups)

        var paths = [IndexPath]()
        for i in count ..< (count + groups.count) {
            paths.append(IndexPath(item: i, section: index))
        }

        collection.insertItems(at: paths)
    }

    func didFetchGroups(groups: [APIClient.Group]) {
        update(.groups(groups))
    }

    func didFetchRooms(rooms: [RoomState]) {
        // sorted is temporary
        update(.rooms(rooms.sorted(by: { $0.id < $1.id })))
    }

    func didFetchActives(actives: [APIClient.ActiveUser]) {
        update(.actives(actives))
    }

    func displayError(title: String, description: String?) {
        let banner = FloatingNotificationBanner(
            title: title,
            subtitle: description,
            style: .danger
        )
        banner.show(cornerRadius: 10, shadowBlurRadius: 15)
    }

    func displayCurrentRoom(_ id: Int) {
        presenter.currentRoom = id

        DispatchQueue.main.async {
            self.collection.reloadData()
        }
    }

    func removeCurrentRoom() {
        presenter.currentRoom = nil

        DispatchQueue.main.async {
            self.collection.reloadData()
        }
    }

    func updateProfileImage() {
        let urlRequest = URLRequest(url: Configuration.cdn.appendingPathComponent("/images/" + UserDefaults.standard.string(forKey: "image")!))

        downloader.download(urlRequest, completion: { response in
            switch response.result {
            case let .success(image):
                self.profileImageView!.image = image
            case .failure:
                break
            }
        })
    }
}

extension HomeViewController {
    enum Update {
        case rooms([RoomState])
        case actives([APIClient.ActiveUser])
        case groups([APIClient.Group])
    }

    func update(_ update: Update) {
        refresh.endRefreshing()

        updateQueue.append(update)
        if updateQueue.count == 1 {
            reloadData()
        }
    }

    private func reloadData() {
        guard let data = updateQueue.first else {
            return
        }

        // @TODO FIX THIS SHIT
        switch data {
        case let .rooms(rooms):
            presenter.set(rooms: rooms)
            collection.reloadSections(IndexSet(integer: presenter.numberOfSections - 1))
        case let .actives(actives):
            let previous = presenter.index(of: .activeList)
            presenter.set(actives: actives)
            if actives.isEmpty {
                if let index = previous {
                    collection.deleteSections(IndexSet(integer: index))
                }
            } else {
                if let index = previous {
                    UIView.performWithoutAnimation {
                        self.collection.reloadSections(IndexSet(integer: index))
                    }
                } else {
                    collection.insertSections(IndexSet(integer: presenter.index(of: .activeList)!))
                }
            }

        case let .groups(groups):

            let previous = presenter.index(of: .groupList)
            presenter.set(groups: groups)

            if let index = previous {
                UIView.performWithoutAnimation {
                    self.collection.reloadSections(IndexSet(integer: index))
                }
            } else {
                collection.insertSections(IndexSet(integer: presenter.index(of: .groupList)!))
            }
        }

        updateQueue.removeFirst()
        reloadData()
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, willDisplay _: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if presenter.sectionType(for: indexPath.section) != .groupList {
            return
        }

        if indexPath.item == presenter.numberOfItems(for: indexPath.section) - 2 {
            output.fetchMoreGroups()
        }
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch presenter.sectionType(for: indexPath.section) {
        case .activeList:
            let user = presenter.item(for: indexPath, ofType: APIClient.ActiveUser.self)

            let options = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            options.addAction(
                UIAlertAction(title: NSLocalizedString("view_profile", comment: ""), style: .default, handler: { _ in
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(SceneFactory.createProfileViewController(id: user.id), animated: true)
                    }
                })
            )

            options.addAction(
                UIAlertAction(title: NSLocalizedString("join_room", comment: ""), style: .default, handler: { _ in
                    DispatchQueue.main.async {
                        self.output.didSelectRoom(room: Int(user.currentRoom))
                    }
                })
            )

            options.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel))

            present(options, animated: true)
        case .roomList:
            let room = presenter.item(for: indexPath, ofType: RoomState.self)
            output.didSelectRoom(room: Int(room.id))
        case .noRooms:
            return
        case .groupList:
            if indexPath.item == 0 {
                return present(SceneFactory.createGroupCreationViewController(), animated: true)
            }

            let group = presenter.item(for: IndexPath(item: indexPath.item - 1, section: indexPath.section), ofType: APIClient.Group.self)
            navigationController?.pushViewController(SceneFactory.createGroupViewController(id: group.id), animated: true)
        }
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        return presenter.numberOfSections
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection index: Int) -> Int {
        return presenter.numberOfItems(for: index)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch presenter.sectionType(for: indexPath.section) {
        case .activeList:
            let cell = collectionView.dequeueReusableCell(withClass: ActiveUserCell.self, for: indexPath)
            presenter.configure(item: cell, for: indexPath)
            return cell
        case .roomList:
            let cell = collectionView.dequeueReusableCell(withClass: RoomCell.self, for: indexPath)
            presenter.configure(item: cell, for: indexPath)
            return cell
        case .groupList:
            let cell = collectionView.dequeueReusableCell(withClass: GroupCell.self, for: indexPath)
            presenter.configure(item: cell, for: indexPath)
            return cell
        case .noRooms:
            return collectionView.dequeueReusableCell(withClass: EmptyRoomCollectionViewCell.self, for: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            return collection.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }

        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: CollectionViewSectionTitle.self, for: indexPath)

        cell.label.text = presenter.title(for: indexPath.section)

        if presenter.sectionType(for: indexPath.section) == .groupList {
            cell.label.font = .rounded(forTextStyle: .title1, weight: .bold)
        } else {
            cell.label.font = .rounded(forTextStyle: .largeTitle, weight: .heavy)
        }

        return cell
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withClass: CollectionViewSectionTitle.self, for: indexPath)

        return header.systemLayoutSizeFitting(
            CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if rooms.count == 0 {
            return CGSize.zero
        }

        return collection.collectionView(collectionView, layout: layout, referenceSizeForFooterInSection: section)
    }
}
