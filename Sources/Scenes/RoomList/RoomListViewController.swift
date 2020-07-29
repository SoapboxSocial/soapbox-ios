//
//  RoomListViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 29.07.20.
//

import UIKit

protocol RoomListViewControllerOutput: class {
    func loadRooms()
    func didSelectRoom(id: Int)
}

class RoomListViewController: UIViewController {
    enum CellIdentifier: String {
        case room
        case empty
    }

    var rooms: UICollectionView!

    var roomsData = [APIClient.Room]()

    var currentRoom: Int?

    var output: RoomListViewControllerOutput!

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
        output.loadRooms()

        view.addSubview(rooms)
    }

    @objc
    private func didPullToRefresh() {
        output.loadRooms()
    }
}

extension RoomListViewController: RoomListPresenterOutput {
    func changedCurrentRoom(_ currentRoom: Int) {
        self.currentRoom = currentRoom

        DispatchQueue.main.async {
            self.rooms.reloadData()
        }
    }

    func fetchedRoomList(_ rooms: [APIClient.Room]) {
        roomsData = rooms

        DispatchQueue.main.async {
            self.rooms.reloadData()
        }
    }

    func didBeginRefreshing() {
        rooms.refreshControl?.beginRefreshing()
    }

    func didEndRefreshing() {
        rooms.refreshControl?.endRefreshing()
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

        output.didSelectRoom(id: roomsData[index.item].id)
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
