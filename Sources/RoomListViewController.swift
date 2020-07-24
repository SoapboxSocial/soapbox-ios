//
// Created by Dean Eigenmann on 22.07.20.
//

import UIKit

protocol RoomListViewDelegate {
    func didSelectRoom(room: RoomData)
}

class RoomListViewController: UIViewController {

    enum CellIdentifier: String {
        case room = "room"
        case empty = "empty"
    }

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

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        // @todo we probably want to move up buttons and other stuff due to iphone x insets
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
            return collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.empty.rawValue, for: indexPath)
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.room.rawValue, for: indexPath) as! RoomCell
        return cell
    }
}

extension RoomListViewController: UICollectionViewDelegate {
    public func collectionView(_: UICollectionView, didSelectItemAt index: IndexPath) {
        if roomsData.count == 0 {
            return
        }

        delegate?.didSelectRoom(room: RoomData(id: index.item, title: "", members: [Member]()))
    }
}

extension RoomListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        if roomsData.count == 0 {
            return CGSize(width: collectionView.frame.width, height: getEmptyHeight())
        }

        return CGSize(width: collectionView.frame.width, height: 300)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }

    private func getEmptyHeight() -> CGFloat {
        var verticalSafeAreaInset = CGFloat(0.0)
        if #available(iOS 11.0, *) {
            verticalSafeAreaInset = view.safeAreaInsets.bottom + view.safeAreaInsets.top
        }

        return view.frame.height - verticalSafeAreaInset
    }
}
