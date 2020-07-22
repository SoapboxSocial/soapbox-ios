//
// Created by Dean Eigenmann on 22.07.20.
//

import UIKit

protocol RoomListViewDelegate {
    func didSelectRoom(_: RoomData?)
}

class RoomListViewController: UIViewController {
    let cellId = "room"

    var delegate: RoomListViewDelegate?

    var rooms: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = UICollectionViewFlowLayout()

        rooms = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        rooms.dataSource = self
        rooms.alwaysBounceVertical = true
        rooms.register(RoomCell.self, forCellWithReuseIdentifier: cellId)
        rooms.delegate = self
        rooms.backgroundColor = .clear

        view.backgroundColor = .clear

        let refresh = UIRefreshControl()
        rooms.refreshControl = refresh
        refresh.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)

        view.addSubview(rooms)
    }

    @objc
    private func didPullToRefresh(sender: UIRefreshControl) {
        // Do you your api calls in here, and then asynchronously remember to stop the
        // refreshing when you've got a result (either positive or negative)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            sender.endRefreshing()
        })
    }
}

extension RoomListViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! RoomCell
        return cell
    }
}

extension RoomListViewController: UICollectionViewDelegate {
    public func collectionView(_: UICollectionView, didSelectItemAt _: IndexPath) {
        delegate?.didSelectRoom(nil)
    }
}

extension RoomListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 300)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }
}
