//
// Created by Dean Eigenmann on 22.07.20.
//

import NotificationBannerSwift
import UIKit

protocol RoomListViewDelegate {
    func currentRoom() -> Int?
    func didSelectRoom(id: Int)
    
    func didBeginSearching()
    func didEndSearching()
}

class RoomListViewController: UIViewController {
    enum CellIdentifier: String {
        case room
        case empty
        case footer
        case user
    }

    var delegate: RoomListViewDelegate?

    var rooms: UICollectionView!
    var searchController: UISearchController!

    var api: APIClient

    var roomsData = [APIClient.Room]()
    var users = [APIClient.User]()

    var currentRoom: Int?

    init(api: APIClient) {
        self.api = api
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        rooms = UICollectionView(frame: view.frame, collectionViewLayout: UICollectionViewFlowLayout())
        rooms.dataSource = self
        rooms.alwaysBounceVertical = true
        rooms.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CellIdentifier.footer.rawValue)
        rooms.register(RoomCell.self, forCellWithReuseIdentifier: CellIdentifier.room.rawValue)
        rooms.register(RoomListEmptyCell.self, forCellWithReuseIdentifier: CellIdentifier.empty.rawValue)
        rooms.register(UserCell.self, forCellWithReuseIdentifier: CellIdentifier.user.rawValue)
        rooms.delegate = self
        rooms.backgroundColor = .clear

        view.backgroundColor = .clear

        let refresh = UIRefreshControl()
        rooms.refreshControl = refresh
        refresh.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)

        rooms.refreshControl?.beginRefreshing()
        loadData()

        view.addSubview(rooms)

        let item = UIBarButtonItem(title: "@" + UserDefaults.standard.string(forKey: "username")!, style: .plain, target: self, action: #selector(openProfile))
        item.tintColor = .black
        navigationItem.leftBarButtonItem = item

        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false

        let scb = searchController.searchBar
        scb.tintColor = UIColor.secondaryBackground
        scb.returnKeyType = .default
        scb.delegate = self

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    @objc private func openProfile() {
        let id = UserDefaults.standard.integer(forKey: "id")
        if id == 0 {
            return (UIApplication.shared.delegate as! AppDelegate).transitionToLoginView()
        }

        let profile = ProfileViewController(id: id)
        navigationController?.pushViewController(profile, animated: true)
    }

    @objc private func didPullToRefresh() {
        loadData()
    }

    private func loadData() {
        currentRoom = delegate?.currentRoom()

        api.rooms { result in
            DispatchQueue.main.async {
                self.rooms.refreshControl?.endRefreshing()
            }

            switch result {
            case .failure:
                self.roomsData = []

                let banner = FloatingNotificationBanner(
                    title: NSLocalizedString("failed_to_load_rooms", comment: ""),
                    subtitle: NSLocalizedString("please_try_again_later", comment: ""),
                    style: .danger
                )
                banner.show(cornerRadius: 10, shadowBlurRadius: 15)

            case let .success(rooms):
                self.roomsData = rooms

                if let current = self.currentRoom {
                    self.roomsData.sort {
                        ($0.id == current) && !($1.id == current)
                    }
                }
            }

            DispatchQueue.main.async {
                self.rooms.reloadData()
            }
        }
    }
}

extension RoomListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, text != "" else {
            return
        }

        api.search(text) { result in
            switch result {
            case .failure:
                self.users = []
            case let .success(users):
                self.users = users
            }

            DispatchQueue.main.async {
                self.rooms.reloadData()
            }
        }
    }
}

extension RoomListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

extension RoomListViewController: UISearchControllerDelegate {
    func didDismissSearchController(_: UISearchController) {
        DispatchQueue.main.async {
            self.delegate?.didEndSearching()
            self.users = []
            self.rooms.reloadData()
        }
    }

    func didPresentSearchController(_: UISearchController) {
        DispatchQueue.main.async {
            self.delegate?.didBeginSearching()
            self.rooms.reloadData()
        }
    }
}

extension RoomListViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        if searchController.isActive {
            return users.count
        }

        if roomsData.count == 0 {
            return 1
        }

        return roomsData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if searchController.isActive {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.user.rawValue, for: indexPath) as! UserCell
            cell.setup(user: users[indexPath.item])
            return cell
        }

        if roomsData.count == 0 {
            return collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.empty.rawValue, for: indexPath)
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.room.rawValue, for: indexPath) as! RoomCell

        let item = roomsData[indexPath.item]

        if item.id == currentRoom {
            cell.setup(style: .current, data: item)
        } else {
            cell.setup(style: .normal, data: item)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CellIdentifier.footer.rawValue, for: indexPath)
    }
}

extension RoomListViewController: UICollectionViewDelegate {
    public func collectionView(_: UICollectionView, didSelectItemAt index: IndexPath) {
        if searchController.isActive {
            navigationController?.pushViewController(ProfileViewController(id: users[index.item].id), animated: true)
            return
        }
        
        if roomsData.count == 0 {
            return
        }

        delegate?.didSelectRoom(id: roomsData[index.item].id)
        // @todo probably reload?
    }
}

extension RoomListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        if roomsData.count == 0, !searchController.isActive {
            return CGSize(width: collectionView.frame.width, height: getEmptyHeight())
        }

        return CGSize(width: collectionView.frame.width, height: 105)
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForFooterInSection _: Int) -> CGSize {
        // @todo also check if current room is open, otherwise we additionally do not need this
        if roomsData.count == 0, !searchController.isActive {
            return CGSize.zero
        }

        return CGSize(width: collectionView.frame.width, height: 105)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }

    private func getEmptyHeight() -> CGFloat {
        var inset = CGFloat(0.0)
        if #available(iOS 11.0, *) {
            inset = view.safeAreaInsets.bottom + view.safeAreaInsets.top
        }

        return view.frame.height - inset
    }
}
