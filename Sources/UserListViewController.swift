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

    init(id: Int userListFunc: @escaping APIClient.UserListFunc) {
        self.userListFunc = userListFunc
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
