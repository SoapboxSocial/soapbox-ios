//
//  PinEntryViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 02.08.20.
//

import NotificationBannerSwift
import UIKit

class PinEntryViewController: UIViewController {
    let token: String

    var textField: TextField!

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

        textField = TextField(frame: CGRect(x: 0, y: 0, width: 330, height: 40))
        textField.center = view.center
        textField.keyboardType = .numberPad
        textField.returnKeyType = .next
        textField.placeholder = NSLocalizedString("pin", comment: "")
        view.addSubview(textField)

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        label.text = NSLocalizedString("enter_your_pin_received_by_mail", comment: "")
        label.font = label.font.withSize(20)
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

        let createButton = UIButton(frame: CGRect(x: 0, y: textField.frame.size.height + textField.frame.origin.y + 30, width: view.frame.size.width / 2, height: 40))
        createButton.setTitle(NSLocalizedString("submit", comment: ""), for: .normal)
        createButton.center = CGPoint(x: view.center.x, y: createButton.center.y)
        createButton.layer.cornerRadius = 5
        createButton.layer.borderWidth = 1
        createButton.addTarget(self, action: #selector(submitPin), for: .touchUpInside)
        view.addSubview(createButton)
    }

    @objc func submitPin() {
        textField.resignFirstResponder()
        view.endEditing(true)

        APIClient().submitPin(token: token, pin: textField.text!) { result in
            switch result {
            case .failure(let error):
                if error == .incorrectPin {
                    return self.displayIncorrectPinBanner()
                }

                return self.displayErrorBanner()
            case .success(let response):
                switch response.0 {
                case .success:
                    guard let user = response.1, let expires = response.2 else {
                        return self.displayErrorBanner()
                    }

                    DispatchQueue.main.async {
                        (UIApplication.shared.delegate as! AppDelegate).transitionToLoggedInState(token: self.token, user: user, expires: expires)
                    }
                case .register:
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(RegistrationViewController(token: self.token), animated: true)
                    }
                }
            }
        }
    }

    private func displayIncorrectPinBanner() {
        let banner = NotificationBanner(title: NSLocalizedString("incorrect_pin", comment: ""), style: .danger)
        banner.show()
    }

    private func displayErrorBanner() {
        let banner = FloatingNotificationBanner(
            title: NSLocalizedString("something_went_wrong", comment: ""),
            subtitle: NSLocalizedString("please_try_again_later", comment: ""),
            style: .danger
        )
        banner.show(cornerRadius: 10, shadowBlurRadius: 15)
    }
}
