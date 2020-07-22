//
// Created by Dean Eigenmann on 22.07.20.
//

import UIKit

protocol RoomListViewDelegate {
    func didSelectRoom(_: RoomStruct?);
}

class RoomListViewController: UIViewController {

    var delegate: RoomListViewDelegate?

    var rooms: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = UICollectionViewFlowLayout()
        rooms = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        rooms.dataSource = self
        rooms.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "foo")
        rooms.delegate = self
        rooms.backgroundColor = .clear
        view.backgroundColor = .clear


        view.addSubview(rooms)
    }
}

extension RoomListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "foo", for: indexPath)
        cell.backgroundColor = .clear
        cell.frame = CGRect(origin: cell.frame.origin, size: CGSize(width: view.frame.size.width, height: 300))

        let content = UIView(frame: CGRect(x: 15, y: 15, width: cell.frame.size.width - 30, height: cell.frame.size.height - 30))
        content.backgroundColor = .white
        content.layer.cornerRadius = 8
        content.layer.masksToBounds = true
        cell.addSubview(content)

        return cell
    }

}

extension RoomListViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectRoom(nil)
    }
}

extension RoomListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 300)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}