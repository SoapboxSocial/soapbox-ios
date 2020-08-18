//
//  UserListViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 10.08.20.
//

import NotificationBannerSwift
import UIKit

class FollowerListViewController: UIViewController {
    private let id: Int
    private let userListFunc: APIClient.FollowerListFunc

    private let cellIdentifier = "cell"
    private let footerIdentifier = "footer"

    var users = [APIClient.User]()

    private var userList: UICollectionView!

    init(id: Int, userListFunc: @escaping APIClient.FollowerListFunc) {
        self.id = id
        self.userListFunc = userListFunc
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        userList = UICollectionView(frame: view.frame, collectionViewLayout: UICollectionViewFlowLayout())
        userList.dataSource = self
        userList.alwaysBounceVertical = true
        userList.register(UserCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        // @TODO THIS IS HACKY
        userList.register(UICollectionViewCell.self, forCellWithReuseIdentifier: footerIdentifier)
        userList.delegate = self
        userList.backgroundColor = .clear
        userList.reloadData()

        view.addSubview(userList)

        loadData()
    }

    private func loadData() {
        userListFunc(id) { result in
            switch result {
            case .failure:
                let banner = FloatingNotificationBanner(
                    title: NSLocalizedString("something_went_wrong", comment: ""),
                    subtitle: NSLocalizedString("please_try_again_later", comment: ""),
                    style: .danger
                )
                banner.show(cornerRadius: 10, shadowBlurRadius: 15)
            case let .success(list):
                self.users = list
            }

            DispatchQueue.main.async {
                self.userList.reloadData()
            }
        }
    }
}

extension FollowerListViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        users.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == users.count {
            return collectionView.dequeueReusableCell(withReuseIdentifier: footerIdentifier, for: indexPath)
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! UserCell
        cell.setup(user: users[indexPath.item])
        return cell
    }
}

extension FollowerListViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.pushViewController(ProfileViewController(id: users[indexPath.item].id), animated: true)
    }
}

extension FollowerListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 105)
    }
}
