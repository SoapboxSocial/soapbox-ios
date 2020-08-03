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

        usernameTextField = TextField(frame: CGRect(x: 0, y: 100, width: 330, height: 40))
        usernameTextField.center = CGPoint(x: view.center.x, y: usernameTextField.center.y)
        usernameTextField.placeholder = "Username"
        view.addSubview(usernameTextField)

        displayName = TextField(frame: CGRect(x: 0, y: 0, width: 330, height: 40))
        
        displayName.center = CGPoint(x: view.center.x, y: view.center.y)
        displayName.placeholder = "Display Name"
        view.addSubview(displayName)
        
        usernameTextField.frame = CGRect(origin: CGPoint(x: usernameTextField.frame.origin.x, y: displayName.frame.origin.y - (displayName.frame.size.height + 30)), size: usernameTextField.frame.size)

        let createButton = UIButton(frame: CGRect(x: 0, y: displayName.frame.size.height + displayName.frame.origin.y + 30, width: view.frame.size.width / 2, height: 40))
        createButton.setTitle(NSLocalizedString("create", comment: ""), for: .normal)
        createButton.center = CGPoint(x: view.center.x, y: createButton.center.y)
        createButton.layer.cornerRadius = 5
        createButton.layer.borderWidth = 1
        createButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        view.addSubview(createButton)
    }

    @objc private func submit() {

        guard let username = usernameTextField.text, isValidUsername(username) else {
            return showError(text: NSLocalizedString("invalid_username", comment: ""))
        }

        APIClient().register(token: token, username: username, displayName: displayName.text ?? username) { result in
            switch result {
            case .failure(let error):
                if error == .usernameAlreadyExists {
                    return self.showError(text: NSLocalizedString("username_already_exists", comment: ""))
                }

                // @todo handle error nicer
                let banner = FloatingNotificationBanner(
                    title: NSLocalizedString("something_went_wrong", comment: ""),
                    subtitle: NSLocalizedString("please_try_again_later", comment: ""),
                    style: .danger
                )
                banner.show(cornerRadius: 10, shadowBlurRadius: 15)
            case .success(let user, let expires):
                DispatchQueue.main.async {
                    (UIApplication.shared.delegate as! AppDelegate).transitionToLoggedInState(token: self.token, user: user, expires: expires)
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
    
    private func showError(text: String) {
        let banner = NotificationBanner(title: text, style: .danger)
        banner.show()
    }
}
