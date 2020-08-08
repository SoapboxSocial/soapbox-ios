//
//  ProfileViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 06.08.20.
//

import UIKit
import NotificationBannerSwift

class ProfileViewController: UIViewController {
    private let api = APIClient()
    private let id: Int

    init(id: Int) {
        self.id = id
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background

        api.user(id: id) { result in
            switch result {
            case .failure:
                DispatchQueue.main.async {
                    let banner = FloatingNotificationBanner(
                        title: NSLocalizedString("something_went_wrong", comment: ""),
                        subtitle: NSLocalizedString("please_try_again_later", comment: ""),
                        style: .danger
                    )
                    banner.show(cornerRadius: 10, shadowBlurRadius: 15)
                }
            case let .success(user):
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
        name.textColor = .black
        view.addSubview(name)

        let username = UILabel(frame: CGRect(x: 40, y: name.frame.origin.y + name.frame.size.height, width: view.frame.size.width - 80, height: 20))
        username.text = "@" + user.username
        username.textColor = .black
        view.addSubview(username)
    }
}
