//
//  LoginViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 27.07.20.
//

import NotificationBannerSwift
import UIKit

class LoginViewController: UIViewController {
    var textField: UITextField!
    var textFieldError: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 213 / 255, green: 94 / 255, blue: 163 / 255, alpha: 1)

        textField = UITextField(frame: CGRect(x: 0, y: 0, width: view.frame.size.width / 2, height: 40))
        textField.borderStyle = .roundedRect
        textField.center = view.center
        textField.keyboardType = .emailAddress
        textField.returnKeyType = .next
        textField.placeholder = "Email"
        view.addSubview(textField)
        textField.frame.size.width = view.frame.size.width / 2
        textField.addTarget(self, action: #selector(login), for: .editingDidEndOnExit)

        textFieldError = UILabel(frame: CGRect(x: textField.frame.origin.x, y: textField.frame.origin.y + textField.frame.size.height, width: textField.frame.size.width, height: 40))
        textFieldError.font = textField.font?.withSize(15)
        view.addSubview(textFieldError)

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        label.text = NSLocalizedString("email_login", comment: "")
        label.textAlignment = .center
        label.textColor = .white
        view.addSubview(label)
        label.center = CGPoint(x: view.center.x, y: textField.frame.origin.y - 20)

        let logo = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        logo.text = "🎙️"
        logo.font = logo.font.withSize(64)
        logo.center = CGPoint(x: view.center.x, y: view.frame.size.height / 4)
        logo.textAlignment = .center
        view.addSubview(logo)
    }

    @objc private func login() {
        textField.resignFirstResponder()
        view.endEditing(true)

        guard let email = textField.text, isValidEmail(email) else {
            return setEmailError()
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

    private func setEmailError() {
        textFieldError.text = NSLocalizedString("invalid_email", comment: "")
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
