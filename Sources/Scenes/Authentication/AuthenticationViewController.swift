//
//  AuthenticationViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 12.08.20.
//

import NotificationBannerSwift
import SwiftConfettiView
import UIKit

protocol AuthenticationViewControllerOutput {
    func login(email: String?)
    func submitPin(pin: String?)
    func register(username: String?, displayName: String?)
}

class AuthenticationViewController: UIViewController {
    var output: AuthenticationViewControllerOutput!

    private var contentView: UIView!
    private var scrollView: UIScrollView!
    private var submitButton: Button!

    private var emailTextField: UITextField!

    private var pinTextField: UITextField!

    private var displayNameTextField: UITextField!
    private var usernameTextField: UITextField!

    private var state = AuthenticationInteractor.AuthenticationState.login

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .secondaryBackground

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        contentView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height / 3))
        contentView.center = view.center

        let height = (view.frame.size.height / 3) - 60
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: contentView.frame.size.height - 60))
        scrollView.contentSize = CGSize(width: view.frame.size.width * 4, height: scrollView.frame.size.height)
        scrollView.isScrollEnabled = false
        contentView.addSubview(scrollView)
        view.addSubview(contentView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        submitButton = Button(frame: CGRect(x: (view.frame.size.width - 282) / 2, y: scrollView.frame.height, width: 282, height: 60))
        submitButton.setTitle(NSLocalizedString("submit", comment: ""), for: .normal)
        submitButton.addTarget(self, action: #selector(didSubmit), for: .touchUpInside)
        contentView.addSubview(submitButton)

        let views = [
            setupLoginView(height: height),
            setupPinView(height: height),
            setupRegistrationView(height: height),
            setupNotificationRequestView(height: height),
            setupSuccessfulView(height: height),
        ]

        for (i, state) in views.enumerated() {
            state.frame = CGRect(origin: CGPoint(x: view.frame.size.width * CGFloat(i), y: 0), size: state.frame.size)
            scrollView.addSubview(state)
        }
    }

    @objc private func didSubmit() {
        view.endEditing(true)
        switch state {
        case .login:
            return output.login(email: emailTextField.text)
        case .pin:
            return output.submitPin(pin: pinTextField.text)
        case .registration:
            return output.register(username: usernameTextField.text, displayName: displayNameTextField.text)
        case .requestNotifications, .success: break
        }
    }

    @objc private func keyboardWillHide() {
        UIView.animate(withDuration: 0.3) {
            self.contentView.center = self.view.center
        }
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        let newOrigin = view.frame.height - (keyboardFrame.size.height + contentView.frame.size.height)

        if newOrigin >= contentView.frame.origin.y {
            return
        }

        UIView.animate(withDuration: 0.3) {
            self.contentView.frame.origin.y = newOrigin
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension AuthenticationViewController: AuthenticationPresenterOutput {
    func transitionTo(state: AuthenticationInteractor.AuthenticationState) {
        self.state = state
        scrollView.setContentOffset(CGPoint(x: view.frame.size.width * CGFloat(state.rawValue), y: 0), animated: true)

        if state == .requestNotifications {
            UIView.animate(withDuration: 0.3) {
                self.submitButton.frame = CGRect(origin: CGPoint(x: self.submitButton.frame.origin.x, y: self.view.frame.size.height), size: self.submitButton.frame.size)
            }
        }

        if state == .success {
            let confettiView = SwiftConfettiView(frame: view.bounds)
            view.addSubview(confettiView)
            confettiView.startConfetti()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                confettiView.stopConfetti()
            }
        }
    }

    func displayError(_ style: ErrorStyle, title: String, description: String?) {
        switch style {
        case .normal:
            let banner = NotificationBanner(title: title, subtitle: description, style: .danger)
            banner.show()
        case .floating:
            let banner = FloatingNotificationBanner(title: title, subtitle: description, style: .danger)
            banner.show(cornerRadius: 10, shadowBlurRadius: 15)
        }
    }
}

extension AuthenticationViewController {
    private func setupLoginView(height: CGFloat) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: height))

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 20))
        label.textAlignment = .center
        label.textColor = .white
        label.text = NSLocalizedString("email_login", comment: "")
        label.font = label.font.withSize(20)
        view.addSubview(label)

        emailTextField = TextField(frame: CGRect(x: (view.frame.size.width - 330) / 2, y: label.frame.size.height + 20, width: 330, height: 40))
        emailTextField.keyboardType = .emailAddress
        emailTextField.placeholder = "Email"
        emailTextField.delegate = self
        view.addSubview(emailTextField)

        return view
    }

    private func setupPinView(height: CGFloat) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: height))

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 20))
        label.textAlignment = .center
        label.text = NSLocalizedString("enter_your_pin_received_by_mail", comment: "")
        label.textColor = .white
        label.font = label.font.withSize(20)
        view.addSubview(label)

        pinTextField = TextField(frame: CGRect(x: (view.frame.size.width - 330) / 2, y: label.frame.size.height + 20, width: 330, height: 40))
        pinTextField.keyboardType = .numberPad
        pinTextField.placeholder = NSLocalizedString("pin", comment: "")
        view.addSubview(pinTextField)

        return view
    }

    private func setupRegistrationView(height: CGFloat) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: height))

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 20))
        label.textAlignment = .center
        label.text = NSLocalizedString("create_account", comment: "")
        label.textColor = .white
        label.font = label.font.withSize(20)
        view.addSubview(label)

        let image = EditProfileImageButton(frame: CGRect(x: (view.frame.size.width - 330) / 2, y: label.frame.size.height + 20, width: 90, height: 90))
        view.addSubview(image)

        usernameTextField = TextField(frame: CGRect(x: image.frame.origin.x + image.frame.size.width + 10, y: label.frame.size.height + 20, width: view.frame.size.width - ((image.frame.origin.x * 2) + image.frame.size.width + 10), height: 40))
        usernameTextField.placeholder = NSLocalizedString("username", comment: "")
        usernameTextField.delegate = self
        view.addSubview(usernameTextField)

        displayNameTextField = TextField(frame: CGRect(x: usernameTextField.frame.origin.x, y: usernameTextField.frame.height + usernameTextField.frame.origin.y + 10, width: usernameTextField.frame.size.width, height: 40))
        displayNameTextField.placeholder = NSLocalizedString("display_name", comment: "")
        displayNameTextField.delegate = self
        view.addSubview(displayNameTextField)

        return view
    }

    private func setupNotificationRequestView(height: CGFloat) -> UIView {
        return UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: height))
    }

    private func setupSuccessfulView(height: CGFloat) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: height))

        let label = UILabel(frame: CGRect(x: 0, y: (height / 2) + 30, width: view.frame.size.width, height: 20))
        label.textAlignment = .center
        label.text = NSLocalizedString("welcome_to_voicely", comment: "")
        label.textColor = .white
        label.font = label.font.withSize(20)
        view.addSubview(label)

        return view
    }
}

extension AuthenticationViewController: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
