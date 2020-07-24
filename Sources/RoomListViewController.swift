//
// Created by Dean Eigenmann on 22.07.20.
//

import UIKit

protocol RoomListViewDelegate {
    func didSelectRoom(room: RoomData)
}

class RoomListViewController: UIViewController {
    let cellId = "room"
    let emptyCellId = "empty"

    var delegate: RoomListViewDelegate?

    var rooms: UICollectionView!

    var api: APIClient

    var roomsData: Array<Int>

    init(api: APIClient) {
        self.api = api
        self.roomsData = Array<Int>()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = UICollectionViewFlowLayout()

        rooms = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        rooms.dataSource = self
        rooms.alwaysBounceVertical = true
        rooms.register(RoomCell.self, forCellWithReuseIdentifier: cellId)
        rooms.register(RoomListEmptyCell.self, forCellWithReuseIdentifier: "empty")
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
        self.loadData()
    }

    private func loadData() {
        api.rooms { array in
            DispatchQueue.main.async {
                self.rooms.refreshControl?.endRefreshing()
            }

            guard let data = array else {
                // @todo
                return
            }

            self.roomsData = data

            DispatchQueue.main.async {
                self.rooms.reloadData()
            }
        }
    }
}

extension RoomListViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        if (roomsData.count == 0) {
            return 1
        }

        return roomsData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if roomsData.count == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellId, for: indexPath) as! RoomListEmptyCell
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! RoomCell
        return cell
    }
}

extension RoomListViewController: UICollectionViewDelegate {
    public func collectionView(_: UICollectionView, didSelectItemAt index: IndexPath) {
        delegate?.didSelectRoom(room: RoomData(id: index.item, title: "", members: [Member]()))
    }
}

extension RoomListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        if roomsData.count == 0 {
            return collectionView.frame.size
        }

        return CGSize(width: collectionView.frame.width, height: 300)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }
}
