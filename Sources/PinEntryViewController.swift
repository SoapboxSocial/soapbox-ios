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

    var textField: UITextField!

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

        textField = UITextField(frame: CGRect(x: 0, y: 0, width: view.frame.size.width / 2, height: 40))
        textField.borderStyle = .roundedRect
        textField.center = view.center
        textField.keyboardType = .numberPad
        textField.returnKeyType = .next
        textField.placeholder = NSLocalizedString("pin", comment: "")
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        textField.frame.size.width = view.frame.size.width / 2
        textField.addTarget(self, action: #selector(submitPin), for: .editingDidEndOnExit)

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        label.text = NSLocalizedString("enter_your_pin_received_by_mail", comment: "")
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

    @objc func submitPin() {
        textField.resignFirstResponder()
        view.endEditing(true)

        APIClient().submitPin(token: token, pin: textField.text!) { result in
            switch result {
            case .failure:
                let banner = FloatingNotificationBanner(
                    title: NSLocalizedString("something_went_wrong", comment: ""),
                    subtitle: NSLocalizedString("please_try_again_later", comment: ""),
                    style: .danger
                )
                banner.show(cornerRadius: 10, shadowBlurRadius: 15)
            case let .success((state, user)):
                switch state {
                case .success:
                    print(user)
                    let viewController = RoomListViewController(api: APIClient())
                    let nav = NavigationViewController(rootViewController: viewController)
                    viewController.delegate = nav

                    DispatchQueue.main.async {
                        UIApplication.shared.keyWindow?.rootViewController = nav
                    }
                case .register:
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(RegistrationViewController(token: self.token), animated: true)
                    }
                }
            }
        }
    }
}
