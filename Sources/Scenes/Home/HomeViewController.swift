import NotificationBannerSwift
import UIKit

protocol HomeViewControllerOutput {
    func fetchRooms()
    func didSelectRoom(room: Int)
}

class HomeViewController: UIViewController {
    private var currentRoom: Int?

    private let refresh = UIRefreshControl()

    var collection: UICollectionView!

    var output: HomeViewControllerOutput!

    private var rooms = [RoomState]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        collection = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collection.automaticallyAdjustsScrollIndicatorInsets = false
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .clear

        collection.register(supplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: CollectionViewSectionTitle.self)
        collection.register(cellWithClass: EmptyRoomCollectionViewCell.self)
        collection.register(cellWithClass: RoomCell.self)

        collection.refreshControl = refresh
        refresh.addTarget(self, action: #selector(loadData), for: .valueChanged)

        view.addSubview(collection)

        loadData()
    }

    @objc private func loadData() {
        refresh.beginRefreshing()
        output.fetchRooms()
    }
}

extension HomeViewController: HomePresenterOutput {
    func didFetchRooms(rooms: [RoomState]) {
        self.rooms = rooms

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
        currentRoom = id

        DispatchQueue.main.async {
            self.collection.reloadData()
        }
    }

    func removeCurrentRoom() {
        currentRoom = nil

        DispatchQueue.main.async {
            self.collection.reloadData()
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if rooms.count == 0 {
            return
        }
        
        let room = rooms[indexPath.item]
        output.didSelectRoom(room: Int(room.id))
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        if rooms.count > 0 {
            return rooms.count
        }

        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if rooms.count == 0 {
            return collectionView.dequeueReusableCell(withClass: EmptyRoomCollectionViewCell.self, for: indexPath)
        }

        let room = rooms[indexPath.item]

        let cell = collectionView.dequeueReusableCell(withClass: RoomCell.self, for: indexPath)
        cell.members = room.members

        cell.title.text = {
            if room.name != "" {
                return room.name
            }

            return NSLocalizedString("listen_in", comment: "")
        }()

        if let id = currentRoom, room.id == id {
            cell.style = .current
        } else {
            cell.style = .normal
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: CollectionViewSectionTitle.self, for: indexPath)
        cell.label.text = NSLocalizedString("rooms", comment: "")
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection _: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
}
