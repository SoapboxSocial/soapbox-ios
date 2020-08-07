//
//  ProfileViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 06.08.20.
//

import UIKit

class ProfileViewController: UIViewController {

    private let api = APIClient()
    private let id: Int

    init(id: Int) {
        self.id = id
        debugPrint(id)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        api.user(id: id) { result in
            switch result {
            case .failure: break
            case .success(let user):
                DispatchQueue.main.async {
                    self.setupView(user: user)
                }
            }
        }
    }

    private func setupView(user: APIClient.User) {

    }
}
