//
//  RoomCreationView.swift
//  Voicely
//
//  Created by Dean Eigenmann on 30.07.20.
//

import UIKit

protocol RoomCreationDelegate {
    func didEnterWithName(_ name: String?)
}

class RoomCreationView: UIView, UITextFieldDelegate {

    var delegate: RoomCreationDelegate?

    private var textField: UITextField!
    private var contentView: UIView!

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if textField != nil { return }

        backgroundColor = .secondaryBackground
        roundCorners(corners: [.topLeft, .topRight], radius: 25.0)

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)

        contentView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height / 3))
        contentView.center = center
        addSubview(contentView)

        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 30))
        titleLabel.font = titleLabel.font.withSize(20)
        titleLabel.text = NSLocalizedString("name_room", comment: "")
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        contentView.addSubview(titleLabel)

        let margin = (frame.size.width - 330) / 2

        textField = TextField(frame: CGRect(x: margin, y: titleLabel.frame.size.height + 20, width: 330, height: 40))
        textField.placeholder = "Email"
        textField.delegate = self
        contentView.addSubview(textField)

        let buttonWidth = (frame.size.width - (margin * 3)) / 2

        let skip = Button(frame: CGRect(x: margin, y: contentView.frame.size.height - 80, width: buttonWidth, height: 60))
        skip.setTitle(NSLocalizedString("skip", comment: ""), for: .normal)
        skip.addTarget(self, action: #selector(skipPressed), for: .touchUpInside)
        contentView.addSubview(skip)

        let create = Button(
            frame: CGRect(x: (margin * 2) + buttonWidth, y: contentView.frame.size.height - 80, width: buttonWidth, height: 60),
            style: .light
        )
        create.setTitle(NSLocalizedString("create", comment: ""), for: .normal)
        create.addTarget(self, action: #selector(skipPressed), for: .touchUpInside)
        contentView.addSubview(create)
    }

    @objc private func dismissKeyboard() {
        endEditing(true)
    }

    @objc private func skipPressed() {
        delegate?.didEnterWithName(nil)
    }

    @objc private func createPressed() {
        delegate?.didEnterWithName(textField.text)
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool { // delegate method
        textField.resignFirstResponder()
        return true
    }

    @objc private func keyboardWillHide() {
        UIView.animate(withDuration: 0.3) {
            self.contentView.center = self.center
        }
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        let newOrigin = frame.height - (keyboardFrame.size.height + self.contentView.frame.size.height)

        if newOrigin >= self.contentView.frame.origin.y {
            return
        }

        UIView.animate(withDuration: 0.3) {
            self.contentView.frame.origin.y = newOrigin
        }
    }
}
