//
//  UserListViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 10.08.20.
//

import UIKit

class FollowerListViewController: UIViewController {

    private let id: Int
    private let userListFunc: APIClient.FollowerListFunc

    private let cellIdentifier = "cell"

    private var users = [APIClient.User]()

    init(id: Int, userListFunc: @escaping APIClient.FollowerListFunc) {
        self.id = id
        self.userListFunc = userListFunc
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        let users = UICollectionView(frame: view.frame, collectionViewLayout: UICollectionViewFlowLayout())
        users.dataSource = self
        users.alwaysBounceVertical = true
        users.register(RoomCell.self, forCellWithReuseIdentifier: CellIdentifier.room.rawValue)
        users.delegate = self
        users.backgroundColor = .clear

        userListFunc(id) { result in
            debugPrint(result)
        }
    }

}

extension FollowerListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        users.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    }
}

extension FollowerListViewController: UICollectionViewDelegate {

}

extension FollowerListViewController: UICollectionViewDelegateFlowLayout {

}
