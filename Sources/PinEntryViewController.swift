//
//  PinEntryViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 02.08.20.
//

import NotificationBannerSwift
import UIKit

class PinEntryViewController: AbstractRegistrationProcessViewController {
    let token: String

    var textField: TextField!

    init(token: String) {
        self.token = token
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupContentView(_ view: UIView) {
        let label = UILabel(frame: CGRect(x: view.frame.size.width, y: 0, width: view.frame.size.width, height: 20))
        label.text = NSLocalizedString("enter_your_pin_received_by_mail", comment: "")
        label.textColor = .white
        label.font = label.font.withSize(20)
        view.addSubview(label)

        textField = TextField(frame: CGRect(x: (view.frame.size.width - 330) / 2, y: label.frame.size.height + 20, width: 330, height: 40))
        textField.keyboardType = .numberPad
        textField.placeholder = NSLocalizedString("pin", comment: "")
        view.addSubview(textField)
    }

    @objc override func didSubmit() {
        textField.resignFirstResponder()
        view.endEditing(true)

        APIClient().submitPin(token: token, pin: textField.text!) { result in
            switch result {
            case let .failure(error):
                if error == .incorrectPin {
                    return self.displayIncorrectPinBanner()
                }

                return self.displayErrorBanner()
            case let .success(response):
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
