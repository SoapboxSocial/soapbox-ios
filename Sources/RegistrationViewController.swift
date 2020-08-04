//
//  RegistrationViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 03.08.20.
//

import NotificationBannerSwift
import UIKit

class RegistrationViewController: AbstractRegistrationProcessViewController {
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

    override func setupContentView(_ view: UIView) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 20))
        label.textAlignment = .center
        label.text = NSLocalizedString("create_account", comment: "")
        label.textColor = .white
        label.font = label.font.withSize(20)
        view.addSubview(label)

        usernameTextField = TextField(frame: CGRect(x: (view.frame.size.width - 330) / 2, y: label.frame.size.height + 20, width: 330, height: 40))
        usernameTextField.placeholder = "Username"
        view.addSubview(usernameTextField)

        displayName = TextField(frame: CGRect(x: (view.frame.size.width - 330) / 2, y: usernameTextField.frame.height + usernameTextField.frame.origin.y + 10, width: 330, height: 40))
        displayName.placeholder = "Display Name"
        view.addSubview(displayName)
    }

    @objc override func didSubmit() {
        guard let username = usernameTextField.text, isValidUsername(username) else {
            return showError(text: NSLocalizedString("invalid_username", comment: ""))
        }

        APIClient().register(token: token, username: username, displayName: displayName.text ?? username) { result in
            switch result {
            case let .failure(error):
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
            case let .success(user, expires):
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
