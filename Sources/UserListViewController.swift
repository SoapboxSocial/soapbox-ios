//
//  UserListViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 10.08.20.
//

import UIKit

class FollowerListViewController: UIViewController {
    private let id: Int
    private let userListFunc: APIClient.UserListFunc

    init(id _: Int userListFunc: @escaping APIClient.UserListFunc) {
        userListFunc = userListFunc
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
