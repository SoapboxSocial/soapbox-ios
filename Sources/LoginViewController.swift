//
//  LoginViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 27.07.20.
//

import UIKit
import NotificationBannerSwift

class LoginViewController: UIViewController {

    var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 213 / 255, green: 94 / 255, blue: 163 / 255, alpha: 1)

        textField = UITextField(frame: CGRect(x: 0, y: 0, width: view.frame.size.width / 2, height: 40))
        textField.borderStyle = .roundedRect
        textField.center = view.center
        textField.keyboardType = .emailAddress
        textField.returnKeyType = .next
        textField.placeholder = "Email"
        //textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        textField.frame.size.width = view.frame.size.width / 2
        textField.addTarget(self, action: #selector(login), for: .editingDidEndOnExit)

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

    @objc func login() {
        textField.resignFirstResponder()
        view.endEditing(true)

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

            case .success(let token):
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(PinEntryViewController(token: token), animated: true)
                }
            }
        }
    }
}
