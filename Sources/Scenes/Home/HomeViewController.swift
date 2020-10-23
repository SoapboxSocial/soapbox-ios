import AlamofireImage
import NotificationBannerSwift
import UIKit

protocol HomeViewControllerOutput {
    func fetchData()
    func didSelectRoom(room: Int)
    func fetchMe()
}

class HomeViewController: UIViewController {
    private let refresh = UIRefreshControl()
    private let downloader = ImageDownloader()

    private var searchController: UISearchController!

    private var collection: CollectionView!
    private var rooms = [RoomState]()
    private let presenter = HomeCollectionPresenter()

    private var profileImageView: UIImageView!

    var output: HomeViewControllerOutput!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        collection = CollectionView(frame: view.frame, collectionViewLayout: makeLayout())
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .clear

        // @TODO PROBABLY NEED TO ADD FOOTER VIEW
        collection.register(supplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: CollectionViewSectionTitle.self)
        collection.register(cellWithClass: EmptyRoomCollectionViewCell.self)
        collection.register(cellWithClass: RoomCell.self)
        collection.register(cellWithClass: ActiveUserCell.self)

        collection.refreshControl = refresh
        refresh.addTarget(self, action: #selector(loadData), for: .valueChanged)

        view.addSubview(collection)

        let containView = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        containView.backgroundColor = .secondaryBackground
        containView.layer.cornerRadius = 40 / 2
        containView.clipsToBounds = true
        containView.addTarget(self, action: #selector(openProfile), for: .touchUpInside)

        let barButtonItem = UIBarButtonItem(customView: containView)
        navigationItem.leftBarButtonItem = barButtonItem

        profileImageView = UIImageView(frame: containView.frame)
        profileImageView.layer.cornerRadius = containView.frame.size.height / 2
        profileImageView.backgroundColor = .brandColor
        profileImageView.clipsToBounds = true
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        containView.addSubview(profileImageView!)

        let iconConfig = UIImage.SymbolConfiguration(weight: .bold)
        let searchButton = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass", withConfiguration: iconConfig),
            style: .plain,
            target: self,
            action: #selector(openSearch)
        )

        let notificationsButton = UIBarButtonItem(
            image: UIImage(systemName: "bell", withConfiguration: iconConfig),
            style: .plain,
            target: self,
            action: #selector(openNotifications)
        )
        navigationItem.rightBarButtonItems = [notificationsButton, searchButton]
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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

    @objc private func loadData() {
        refresh.beginRefreshing()
        output.fetchData()
    }

    private func makeLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            switch self.presenter.sectionType(for: sectionIndex) {
            case .activeList:
                return self.createActiveListSection()
            case .roomList:
                return self.createRoomListSection()
            case .noRooms:
                return self.createNoRoomsSection()
            }
        }
    }

    private func createNoRoomsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)

        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        let layoutGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension:
            .absolute(view.frame.size.height - 300) // @TODO NOT SURE ABOUT HEIGHT
        )
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize, subitem: layoutItem, count: 1)

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        return layoutSection
    }

    private func createActiveListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)

        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .absolute(96), heightDimension: .absolute(125))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitem: layoutItem, count: 1)

        layoutGroup.interItemSpacing = .fixed(10)

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.interGroupSpacing = 10
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary

        return layoutSection
    }

    private func createRoomListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)

        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(138))

        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize, subitem: layoutItem, count: 1)

        layoutGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        layoutGroup.interItemSpacing = .fixed(20)

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
        presenter.set(rooms: rooms)

        DispatchQueue.main.async {
            self.refresh.endRefreshing()
            self.collection.reloadData()
        }
    }

    func didFetchActives(actives: [APIClient.ActiveUser]) {
        presenter.set(actives: actives)

        DispatchQueue.main.async {
            self.refresh.endRefreshing()
            self.collection.reloadData()
        }
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

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch presenter.sectionType(for: indexPath.section) {
        case .activeList:
            let user = presenter.item(for: indexPath, ofType: APIClient.ActiveUser.self)
            output.didSelectRoom(room: Int(user.currentRoom))
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
        case .activeList:
            let cell = collectionView.dequeueReusableCell(withClass: ActiveUserCell.self, for: indexPath)
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
        cell.label.text = NSLocalizedString("rooms", comment: "")
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
