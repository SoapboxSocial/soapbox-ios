//
// Created by Dean Eigenmann on 22.07.20.
//

import UIKit

protocol RoomListViewDelegate {
    func currentRoom() -> Int?
    func didSelectRoom(id: Int)
}

class RoomListViewController: UIViewController {
    enum CellIdentifier: String {
        case room
        case empty
    }

    var delegate: RoomListViewDelegate?

    var rooms: UICollectionView!

    var api: APIClient

    var roomsData = [APIClient.Room]()

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
        rooms.register(RoomCell.self, forCellWithReuseIdentifier: CellIdentifier.room.rawValue)
        rooms.register(RoomListEmptyCell.self, forCellWithReuseIdentifier: CellIdentifier.empty.rawValue)
        rooms.delegate = self
        rooms.backgroundColor = .clear

        view.backgroundColor = .clear

        let refresh = UIRefreshControl()
        rooms.refreshControl = refresh
        refresh.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)

        rooms.refreshControl?.beginRefreshing()
        loadData()

        view.addSubview(rooms)
    }

    @objc
    private func didPullToRefresh() {
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

extension RoomListViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        if roomsData.count == 0 {
            return 1
        }

        return roomsData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
}

extension RoomListViewController: UICollectionViewDelegate {
    public func collectionView(_: UICollectionView, didSelectItemAt index: IndexPath) {
        if roomsData.count == 0 {
            return
        }

        delegate?.didSelectRoom(id: roomsData[index.item].id)
        // @todo probably reload?
    }
}

extension RoomListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        if roomsData.count == 0 {
            return CGSize(width: collectionView.frame.width, height: getEmptyHeight())
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
