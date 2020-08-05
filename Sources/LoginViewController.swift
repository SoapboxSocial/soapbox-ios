//
//  LoginViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 27.07.20.
//

import NotificationBannerSwift
import UIKit

class LoginViewController: AbstractRegistrationProcessViewController {
    private var textField: TextField!

    override func setupContentView(_ view: UIView) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 20))
        label.textAlignment = .center
        label.textColor = .white
        label.text = NSLocalizedString("email_login", comment: "")
        label.font = label.font.withSize(20)
        view.addSubview(label)

        textField = TextField(frame: CGRect(x: (view.frame.size.width - 330) / 2, y: label.frame.size.height + 20, width: 330, height: 40))
        textField.keyboardType = .emailAddress
        textField.placeholder = "Email"
        textField.delegate = self
        view.addSubview(textField)
    }

    @objc override func didSubmit() {
        textField.resignFirstResponder()
        view.endEditing(true)

        guard let email = textField.text, isValidEmail(email) else {
            return showEmailError()
        }

        APIClient().login(email: textField.text!) { result in
            switch result {
            case .failure:
                // @todo handle error nicer
                let banner = FloatingNotificationBanner(
                    title: NSLocalizedString("something_went_wrong", comment: ""),
                    subtitle: NSLocalizedString("please_try_again_later", comment: ""),
                    style: .danger
                )
                banner.show(cornerRadius: 10, shadowBlurRadius: 15)

            case let .success(token):
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(PinEntryViewController(token: token), animated: true)
                }
            }
        }
    }

    private func showEmailError() {
        let banner = NotificationBanner(title: NSLocalizedString("invalid_email", comment: ""), style: .danger)
        banner.show()
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
