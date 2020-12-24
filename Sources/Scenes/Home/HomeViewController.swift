import AlamofireImage
import DrawerView
import NotificationBannerSwift
import UIKit

protocol HomeViewControllerOutput {
    func fetchData()
    func didSelectRoom(room: Int)
    func fetchMe()
}

class HomeViewController: ViewController {
    private let refresh = UIRefreshControl()
    private let downloader = ImageDownloader()

    private var collection: CollectionView!
    private var rooms = [RoomState]()
    private let presenter = HomeCollectionPresenter()

    var output: HomeViewControllerOutput!

    private var updateQueue = [Update]()

    private var storyDrawer: DrawerView!
    private var creationView: CreateStoryView?

    private var ownStories = [APIClient.Story]()

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
        collection.register(cellWithClass: StoryCell.self)
        collection.register(cellWithClass: CreateStoryCell.self)

        collection.refreshControl = refresh
        refresh.addTarget(self, action: #selector(loadData), for: .valueChanged)

        view.addSubview(collection)

        let iconConfig = UIImage.SymbolConfiguration(weight: .bold)

        let profileButton = UIBarButtonItem(
            image: UIImage(systemName: "person.crop.circle", withConfiguration: iconConfig),
            style: .plain,
            target: self,
            action: #selector(openProfile)
        )

        let searchButton = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass", withConfiguration: iconConfig),
            style: .plain,
            target: self,
            action: #selector(openSearch)
        )

        navigationItem.leftBarButtonItems = [profileButton, searchButton]

        let notificationsButton = UIBarButtonItem(
            image: UIImage(systemName: "bell", withConfiguration: iconConfig),
            style: .plain,
            target: self,
            action: #selector(openNotifications)
        )
        navigationItem.rightBarButtonItems = [notificationsButton]

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
        let id = UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId)
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

    @objc private func loadData() {
        refresh.beginRefreshing()
        output.fetchData()
    }

    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            switch self.presenter.sectionType(for: sectionIndex) {
            case .storiesList:
                return self.createStoriesListSection()
            case .roomList:
                return self.createRoomListSection()
            case .noRooms:
                return self.createNoRoomsSection()
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
        if presenter.has(section: .storiesList) {
            heightAbsolute -= 300
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

    private func createStoriesListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)

        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .absolute(64), heightDimension: .absolute(64))
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
    func didFetchRooms(rooms: [RoomState]) {
        // sorted is temporary
        update(.rooms(rooms.sorted(by: { $0.id < $1.id })))
    }

    func didFetchFeed(_ feed: [APIClient.StoryFeed]) {
        update(.feed(feed))
    }

    func didFetchOwnStories(_ stories: [APIClient.Story]) {
        let has = stories.count >= 1

        ownStories = stories

        update(.ownStory(has))
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
}

extension HomeViewController {
    enum Update {
        case ownStory(Bool)
        case rooms([RoomState])
        case feed([APIClient.StoryFeed])
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
        case let .feed(feed):
            presenter.set(stories: feed)
            collection.reloadSections(IndexSet(integer: 0))
        case let .ownStory(has):
            presenter.set(hasOwnStory: has)
            collection.reloadSections(IndexSet(integer: 0))
        }

        updateQueue.removeFirst()
        reloadData()
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch presenter.sectionType(for: indexPath.section) {
        case .storiesList:
            if presenter.currentRoom != nil {
                let banner = FloatingNotificationBanner(title: NSLocalizedString("cant_listen_in_room", comment: ""), style: .info)
                banner.show()
                return
            }

            if indexPath.item == 0 {
                return openCreateStory()
            }

            var feed: APIClient.StoryFeed
            if indexPath.item == 1, presenter.hasOwnStory {
                feed = APIClient.StoryFeed(
                    user: APIClient.User(
                        id: UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId),
                        displayName: UserDefaults.standard.string(forKey: UserDefaultsKeys.userDisplay) ?? "",
                        username: UserDefaults.standard.string(forKey: UserDefaultsKeys.username) ?? "",
                        email: "",
                        image: UserDefaults.standard.string(forKey: UserDefaultsKeys.userImage)
                    ),
                    stories: ownStories
                )
            } else {
                feed = presenter.item(for: indexPath, ofType: APIClient.StoryFeed.self)
            }

            let vc = StoriesViewController(feed: feed)
            vc.modalPresentationStyle = .fullScreen

            present(vc, animated: true)
        case .roomList:
            let room = presenter.item(for: indexPath, ofType: RoomState.self)
            output.didSelectRoom(room: Int(room.id))
        case .noRooms:
            return
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
        case .storiesList:
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withClass: CreateStoryCell.self, for: indexPath)
                if presenter.hasOwnStory {
                    cell.profileImage.image = UIImage(systemName: "waveform", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
                    cell.profileImage.tintColor = .white
                } else {
                    cell.profileImage.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + UserDefaults.standard.string(forKey: UserDefaultsKeys.userImage)!))
                }

                return cell
            }

            if indexPath.item == 1, presenter.hasOwnStory {
                let cell = collectionView.dequeueReusableCell(withClass: StoryCell.self, for: indexPath)
                cell.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + UserDefaults.standard.string(forKey: UserDefaultsKeys.userImage)!))
                return cell
            }

            let cell = collectionView.dequeueReusableCell(withClass: StoryCell.self, for: indexPath)
            presenter.configure(item: cell, for: indexPath)
            return cell
        case .roomList:
            let cell = collectionView.dequeueReusableCell(withClass: RoomCell.self, for: indexPath)
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
        cell.label.font = .rounded(forTextStyle: .largeTitle, weight: .heavy)

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

extension HomeViewController: CreateStoryViewDelegate, DrawerViewDelegate {
    func openCreateStory() {
        creationView = CreateStoryView()
        creationView!.delegate = self

        storyDrawer = DrawerView(withView: creationView!)
        storyDrawer!.cornerRadius = 25.0
        storyDrawer!.delegate = self
        storyDrawer!.attachTo(view: (navigationController?.view)!)
        storyDrawer!.backgroundEffect = nil
        storyDrawer!.snapPositions = [.closed, .open]
        storyDrawer!.backgroundColor = .brandColor
        storyDrawer!.childScrollViewsPanningCanDismissDrawer = false

        navigationController?.view.addSubview(storyDrawer)

        creationView!.autoPinEdgesToSuperview()

        storyDrawer!.setPosition(.closed, animated: false)
        storyDrawer!.setPosition(.open, animated: true) { _ in
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }

    // This removes the pan functionality to close the drawer temporarily.
    // We do this because if the user drags their thumb while recording things go weird.
    func didStartRecording() {
        storyDrawer.enabled = false
    }

    func didEndRecording() {
        storyDrawer.enabled = true
    }

    func didFailToRequestPermission() {}

    func didFinishUploading(_: CreateStoryView) {
        closeStoryDrawer()
    }

    func didCancel() {
        closeStoryDrawer()
    }

    func drawer(_: DrawerView, didTransitionTo position: DrawerPosition) {
        if position != .closed {
            return
        }

        creationView?.stop()
        creationView = nil

        storyDrawer.removeFromSuperview()
        storyDrawer = nil
    }

    private func closeStoryDrawer() {
        storyDrawer.setPosition(.closed, animated: true, completion: { _ in
            self.output.fetchData()
        })
    }
}
