//
//  AbstractRegistrationProcessViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 04.08.20.
//

import UIKit

// @todo probably can find a better name

class AbstractRegistrationProcessViewController: UIViewController, UITextFieldDelegate {

    private var contentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .secondaryBackground

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        contentView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height / 3))
        contentView.center = view.center
        view.addSubview(contentView)

        setupContentView(contentView)

        let submitButton = Button(frame: CGRect(x: (view.frame.size.width - 282) / 2, y: contentView.frame.size.height - 80, width: 282, height: 60))
        submitButton.setTitle(NSLocalizedString("submit", comment: ""), for: .normal)
        submitButton.addTarget(self, action: #selector(didSubmit), for: .touchUpInside)
        contentView.addSubview(submitButton)
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool { // delegate method
        textField.resignFirstResponder()
        return true
    }

    func setupContentView(_ view: UIView) {}

    @objc func didSubmit() {}

    @objc private func keyboardWillHide() {
        UIView.animate(withDuration: 0.3) {
            self.contentView.center = self.view.center
        }
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        let newOrigin = self.view.frame.height - (keyboardFrame.size.height + self.contentView.frame.size.height)

        if newOrigin >= self.contentView.frame.origin.y {
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
