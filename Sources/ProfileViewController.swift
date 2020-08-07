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
        let image = UIView(frame: CGRect(x: 40, y: (navigationController?.navigationBar.frame.origin.y)! + (navigationController?.navigationBar.frame.size.height)! + 20, width: 75, height: 75))
        image.layer.cornerRadius = 75 / 2
        image.backgroundColor = .secondaryBackground
        view.addSubview(image)

        let name = UILabel(frame: CGRect(x: 40, y: image.frame.origin.y + image.frame.size.height + 20, width: view.frame.size.width - 80, height: 20))
        name.text = user.displayName
        name.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        view.addSubview(name)

        let username = UILabel(frame: CGRect(x: 40, y: name.frame.origin.y + name.frame.size.height, width: view.frame.size.width - 80, height: 20))
        username.text = "@" + user.username
        view.addSubview(username)
    }
}
