//
//  LoginViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 27.07.20.
//

import NotificationBannerSwift
import UIKit

class LoginViewController: UIViewController {

    private var contentView: UIView!
    private var textField: TextField!
    private var submitButton: Button!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 133 / 255, green: 90 / 255, blue: 255 / 255, alpha: 1)

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        contentView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height / 3))
        contentView.center = view.center
        view.addSubview(contentView)

        textField = TextField(frame: CGRect(x: (view.frame.size.width - 330) / 2, y: 40, width: 330, height: 40))
        textField.keyboardType = .emailAddress
        textField.placeholder = "Email"
        contentView.addSubview(textField)

        submitButton = Button(frame: CGRect(x: (view.frame.size.width - 282) / 2, y: contentView.frame.size.height - 80, width: 282, height: 60))
        submitButton.setTitle("Sign Up", for: .normal)
        submitButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        contentView.addSubview(submitButton)
    }

    @objc private func keyboardWillHide() {
        UIView.animate(withDuration: 0.3) {
            self.contentView.center = self.view.center
        }
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        UIView.animate(withDuration: 0.3) {
            self.contentView.frame.origin.y = (self.view.frame.height - (keyboardFrame.size.height + self.contentView.frame.size.height))
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func login() {
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
