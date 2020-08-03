//
//  RegistrationViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 03.08.20.
//

import UIKit
import NotificationBannerSwift

class RegistrationViewController: UIViewController {
    let token: String

    var usernameTextField: UITextField!
    var usernameError: UILabel!
    var displayName: UITextField!

    init(token: String) {
        self.token = token
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 213 / 255, green: 94 / 255, blue: 163 / 255, alpha: 1)

        usernameTextField = UITextField(frame: CGRect(x: 0, y: 100, width: view.frame.size.width / 2, height: 40))
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.center = CGPoint(x: view.center.x, y: usernameTextField.center.y)
        usernameTextField.keyboardType = .numberPad
        usernameTextField.returnKeyType = .next
        usernameTextField.placeholder = "Username"
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usernameTextField)

        usernameError = UILabel(frame: CGRect(x: usernameTextField.frame.origin.x, y: usernameTextField.frame.origin.y + usernameTextField.frame.size.height, width: usernameTextField.frame.size.width, height: 40))
        usernameError.font = usernameError.font?.withSize(15)
        view.addSubview(usernameError)

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        label.text = "Username"
        label.textAlignment = .center
        label.textColor = .white
        view.addSubview(label)
        label.center = CGPoint(x: view.center.x, y: usernameTextField.frame.origin.y - 20)

        displayName = UITextField(frame: CGRect(x: 0, y: usernameError.frame.origin.y + usernameError.frame.size.height, width: view.frame.size.width / 2, height: 40))
        displayName.borderStyle = .roundedRect
        displayName.center = CGPoint(x: view.center.x, y: displayName.center.y)
        displayName.keyboardType = .numberPad
        displayName.returnKeyType = .next
        displayName.placeholder = "Username"
        displayName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(displayName)

        let createButton = UIButton(frame: CGRect(x: 0, y: displayName.frame.size.height + displayName.frame.origin.y + 30, width: view.frame.size.width / 2, height: 40))
        createButton.setTitle(NSLocalizedString("create", comment: ""), for: .normal)
        createButton.center = CGPoint(x: view.center.x, y: createButton.center.y)
        createButton.layer.cornerRadius = 5
        createButton.layer.borderWidth = 1
        createButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        view.addSubview(createButton)
    }

    @objc private func submit() {
        usernameError.text = ""

        // @todo validate username
        guard let username = usernameTextField.text, isValidUsername(username) else {
            return self.usernameError.text = NSLocalizedString("invalid_username", comment: "")
        }

        APIClient().register(token: token, username: username, displayName: displayName.text ?? username) { result in
            switch result {
            case .failure(let error):
                if error == .usernameAlreadyExists {
                    self.usernameError.text = NSLocalizedString("username_already_exists", comment: "")
                    return
                }

                // @todo handle error nicer
                let banner = FloatingNotificationBanner(
                    title: NSLocalizedString("something_went_wrong", comment: ""),
                    subtitle: NSLocalizedString("please_try_again_later", comment: ""),
                    style: .danger
                )
                banner.show(cornerRadius: 10, shadowBlurRadius: 15)
            case .success(let user):
                print(user)
                let viewController = RoomListViewController(api: APIClient())
                let nav = NavigationViewController(rootViewController: viewController)
                viewController.delegate = nav

                DispatchQueue.main.async {
                    UIApplication.shared.keyWindow?.rootViewController = nav
                }
            }
        }
    }

    private func isValidUsername(_ username: String) -> Bool {
        if username.count >= 100 || username.count < 3 {
            return false
        }

        let usernameRegexEx = "^([A-Za-z0-9_]+)*$"

        let usernamePred = NSPredicate(format: "SELF MATCHES %@", usernameRegexEx)
        return usernamePred.evaluate(with: username)
    }
}
