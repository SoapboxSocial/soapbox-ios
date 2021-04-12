import AlamofireImage
import UIKit

protocol HomeViewControllerOutput {
    func fetchData()
    func didSelectRoom(room: String)
    func fetchMe()
}

class HomeViewController: ViewControllerWithScrollableContent<UICollectionView> {
    private let refresh = UIRefreshControl()

    private let presenter = HomeCollectionPresenter()

    var output: HomeViewControllerOutput!

    private var ownStories = [APIClient.Story]()

    private let feedbackGenerator: UIImpactFeedbackGenerator = {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        return generator
    }()

    private var notificationButton: BadgedButtonItem = {
        let conf = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        let image = UIImage(systemName: "bell", withConfiguration: conf)?.withTintColor(.brandColor)

        return BadgedButtonItem(with: image)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        content = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        content.delegate = self
        content.dataSource = self
        content.translatesAutoresizingMaskIntoConstraints = false
        content.backgroundColor = .clear

        content.register(supplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: CollectionViewSectionTitle.self)
        content.register(supplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withClass: EmptyCollectionFooterView.self)
        content.register(cellWithClass: EmptyRoomCollectionViewCell.self)
        content.register(cellWithClass: RoomCell.self)
        content.register(cellWithClass: StoryCell.self)
        content.register(cellWithClass: CreateStoryCell.self)
        content.register(cellWithClass: CollectionViewCell.self)

        content.refreshControl = refresh
        refresh.addTarget(self, action: #selector(loadData), for: .valueChanged)

        view.addSubview(content)

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

        navigationItem.leftBarButtonItems = [profileButton]

        navigationItem.rightBarButtonItems = [searchButton, notificationButton]

        notificationButton.tapAction = {
            DispatchQueue.main.async {
                self.openNotifications()
            }
        }

        NSLayoutConstraint.activate([
            content.leftAnchor.constraint(equalTo: view.leftAnchor),
            content.rightAnchor.constraint(equalTo: view.rightAnchor),
            content.topAnchor.constraint(equalTo: view.topAnchor),
            content.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
        feedbackGenerator.impactOccurred()
        feedbackGenerator.prepare()

        let search = SceneFactory.createSearchViewController()
        navigationController?.pushViewController(search, animated: true)
    }

    private func openNotifications() {
        let notifications = SceneFactory.createNotificationsViewController()
        navigationController?.pushViewController(notifications, animated: true)
    }

    @objc private func loadData() {
        refresh.beginRefreshing()
        output.fetchData()
    }

    func openCreateStory() {
        let creationView = StoryCreationViewController()
        present(creationView, animated: true)
    }

    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            switch self.presenter.sectionType(for: sectionIndex) {
            case .storiesList:
                return self.createStoriesListSection()
            case .roomList:
                return self.createRoomListSection()
            case .topRoom:
                return self.createTopRoomSection()
            case .activeUserList:
                return self.createActiveUserSection()
            case .noRooms:
                return self.createNoRoomsSection()
            }
        }

        layout.configuration = UICollectionViewCompositionalLayoutConfiguration()
        layout.configuration.interSectionSpacing = 20
        layout.register(CollectionBackgroundView.self, forDecorationViewOfKind: "background")
        return layout
    }

    private func createNoRoomsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)

        layoutItem.contentInsets = .zero

        var height = view.frame.size.height - 300
        if presenter.has(section: .activeUserList) {
            height -= 300
        }

        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: NSCollectionLayoutDimension.absolute(height))
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

        // @TODO ONLY ADD HEADER WHEN NO ACTIVES
        layoutSection.boundarySupplementaryItems = [createSectionFooter()]

        return layoutSection
    }

    private func createTopRoomSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(138))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)

        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(138))
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize, subitems: [layoutItem])

        layoutGroup.contentInsets = .zero

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        layoutSection.interGroupSpacing = 20

        layoutSection.boundarySupplementaryItems = [createSectionHeader()]

        return layoutSection
    }

    private func createActiveUserSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.33))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.60), heightDimension: .estimated(160))
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize, subitem: layoutItem, count: 3)
        layoutGroup.interItemSpacing = .fixed(20)

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .continuous
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        layoutSection.interGroupSpacing = 10

        layoutSection.boundarySupplementaryItems = [createSectionHeader()]

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
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(105)),
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
    }
}

extension HomeViewController: HomePresenterOutput {
    func has(notifications: Bool) {
        if notifications {
            notificationButton.showBadge()
        } else {
            notificationButton.hideBadge()
        }
    }

    func display(feed: Feed) {
        content.refreshControl?.endRefreshing()

        if let ownStory = feed.ownStory {
            ownStories = ownStory
            presenter.set(hasOwnStory: ownStory.count >= 1)
        }

        if let stories = feed.stories {
            presenter.set(stories: stories)
        }

        if let actives = feed.actives {
            presenter.set(actives: actives)
        }

        if let rooms = feed.rooms {
            handle(rooms: rooms)
        } else {
            handle(rooms: [])
        }

        DispatchQueue.main.async {
            self.content.reloadData()
        }
    }

    func handle(rooms: [RoomAPIClient.Room]) {
        if rooms.isEmpty {
            presenter.removeTopRoom()
            presenter.set(rooms: [])
            return
        }

        var data = rooms
        if presenter.has(section: .activeUserList) {
            let topRoom = { () -> RoomAPIClient.Room? in
                var room: RoomAPIClient.Room?
                if let id = presenter.currentRoom {
                    room = rooms.first(where: { $0.id == id })
                }

                if let room = room {
                    return room
                }

                return rooms.sorted(by: { $0.members.count > $1.members.count }).first
            }()

            if let room = topRoom {
                presenter.set(topRoom: room)
                data.removeAll(where: { $0.id == room.id })
            } else {
                presenter.removeTopRoom()
            }
        }

        presenter.set(rooms: data.sorted(by: { $0.id < $1.id }))
    }

    func displayError(title: String, description: String?) {
        let banner = NotificationBanner(
            title: title,
            subtitle: description,
            style: .danger,
            type: .floating
        )
        banner.show()
    }

    func displayCurrentRoom(_ id: String) {
        presenter.currentRoom = id

        DispatchQueue.main.async {
            self.content.reloadData()
        }
    }

    func removeCurrentRoom() {
        presenter.currentRoom = nil

        DispatchQueue.main.async {
            self.content.reloadData()
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch presenter.sectionType(for: indexPath.section) {
        case .storiesList:
            if presenter.currentRoom != nil {
                let banner = NotificationBanner(
                    title: NSLocalizedString("cant_listen_in_room", comment: ""),
                    style: .info,
                    type: .floating
                )
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
            let room = presenter.item(for: indexPath, ofType: RoomAPIClient.Room.self)
            output.didSelectRoom(room: room.id)
        case .topRoom:
            let room = presenter.item(for: indexPath, ofType: RoomAPIClient.Room.self)
            output.didSelectRoom(room: room.id)
        case .noRooms:
            return
        case .activeUserList:
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
                    cell.profileImage.image = UIImage(
                        systemName: "waveform",
                        withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
                    )
                    cell.profileImage.tintColor = .white
                    cell.profileImage.contentMode = .center
                } else {
                    cell.profileImage.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + UserDefaults.standard.string(forKey: UserDefaultsKeys.userImage)!))
                    cell.profileImage.contentMode = .scaleAspectFill
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
        case .topRoom:
            let cell = collectionView.dequeueReusableCell(withClass: RoomCell.self, for: indexPath)
            presenter.configure(item: cell, for: indexPath)
            return cell
        case .activeUserList:
            let cell = collectionView.dequeueReusableCell(withClass: CollectionViewCell.self, for: indexPath)
            presenter.configure(item: cell, for: indexPath)
            return cell
        case .noRooms:
            return collectionView.dequeueReusableCell(withClass: EmptyRoomCollectionViewCell.self, for: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: EmptyCollectionFooterView.self, for: indexPath)
        case UICollectionView.elementKindSectionHeader:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: CollectionViewSectionTitle.self, for: indexPath)

            if let title = presenter.title(for: indexPath.section) {
                cell.title.text = title
            }

            let section = presenter.sectionType(for: indexPath.section)
            if section == .roomList || section == .topRoom {
                cell.title.font = .rounded(forTextStyle: .largeTitle, weight: .heavy)
            }

            if let subtitle = presenter.subtitle(for: indexPath.section) {
                cell.subtitle.text = subtitle
            }

            return cell
        default:
            fatalError("unknown kind: \(kind)")
        }
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
}
