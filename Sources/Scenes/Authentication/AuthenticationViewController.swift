import NotificationBannerSwift
import SwiftConfettiView
import UIKit

protocol AuthenticationViewControllerOutput {
    func login(email: String?)
    func submitPin(pin: String?)
    func register(username: String?, displayName: String?)
    func showImagePicker()
    func didSelect(image: UIImage)
}

class AuthenticationViewController: UIViewController {
    var output: AuthenticationViewControllerOutput!

    private var imagePicker: ImagePicker!

    private var contentView: UIView!
    private var scrollView: UIScrollView!
    private var submitButton: Button!

    private var emailTextField: TextField!

    private var pinTextField: UITextField!

    private var displayNameTextField: UITextField!
    private var usernameTextField: UITextField!

    private var state = AuthenticationInteractor.AuthenticationState.login

    func inject(pin: String) -> Bool {
        if state != .pin {
            return false
        }

        pinTextField.text = pin
        didSubmit()
        return true
    }

    @objc private func didSubmit() {
        view.endEditing(true)
        submitButton.isEnabled = false
//        switch state {
//        case .login:
//            return output.login(email: emailTextField.text)
//        case .pin:
//            return output.submitPin(pin: pinTextField.text)
//        case .registration:
//            return output.register(username: usernameTextField.text, displayName: displayNameTextField.text)
//        case .requestNotifications, .success: break
//        }
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
        submitButton.isEnabled = true
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
        submitButton.isEnabled = true

        switch style {
        case .normal:
            let banner = NotificationBanner(title: title, subtitle: description, style: .danger)
            banner.show()
        case .floating:
            let banner = FloatingNotificationBanner(title: title, subtitle: description, style: .danger)
            banner.show(cornerRadius: 10, shadowBlurRadius: 15)
        }
    }

    func display(profileImage _: UIImage) {
//        profileImage.image = image
    }

    func displayImagePicker() {
        DispatchQueue.main.async {
            self.imagePicker.present(self)
        }
    }
}

extension AuthenticationViewController {
    @objc private func showImagePicker() {
        output.showImagePicker()
    }

    private func setupNotificationRequestView(height: CGFloat) -> UIView {
        return UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: height))
    }

    private func setupSuccessfulView(height: CGFloat) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: height))

        let label = UILabel(frame: CGRect(x: 0, y: (height / 2) + 30, width: view.frame.size.width, height: 20))
        label.textAlignment = .center
        label.text = NSLocalizedString("welcome", comment: "")
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

extension AuthenticationViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        if image != nil {
            output.didSelect(image: image!)
        }
    }
}
