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

    var textField: UITextField!

    var delegate: RoomCreationDelegate?

    override func layoutSubviews() {
        super.layoutSubviews()

        // @todo add an X button

        backgroundColor = .elementBackground
        layer.cornerRadius = 10.0

        let titleLabel = UILabel(frame: CGRect(x: 0, y: 30, width: frame.size.width, height: 30))
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        titleLabel.text = NSLocalizedString("name_room", comment: "")
        titleLabel.textAlignment = .center
        addSubview(titleLabel)

        // @todo probably want like a, this will let people know what its all about

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        addGestureRecognizer(tap)

        textField = UITextField(frame: CGRect(x: 0, y: titleLabel.frame.size.height + titleLabel.frame.origin.y + 30, width: frame.size.width / 2, height: 40))
        textField.borderStyle = .roundedRect
        textField.center = CGPoint(x: center.x, y: textField.center.y)
        textField.clearButtonMode = .always
        textField.textColor = .highlight
        textField.placeholder = NSLocalizedString("enter_name", comment: "")
        textField.layer.borderColor = UIColor.highlight.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.delegate = self
        addSubview(textField)

        let createButton = UIButton(frame: CGRect(x: 0, y: textField.frame.size.height + textField.frame.origin.y + 30, width: frame.size.width / 2, height: 40))
        createButton.setTitle(NSLocalizedString("create", comment: ""), for: .normal)
        createButton.setTitleColor(.highlight, for: .normal)
        createButton.backgroundColor = .clear
        createButton.center = CGPoint(x: center.x, y: createButton.center.y)
        createButton.layer.cornerRadius = 5
        createButton.layer.borderWidth = 1
        createButton.layer.borderColor = UIColor.highlight.cgColor
        createButton.addTarget(self, action: #selector(createPressed), for: .touchUpInside)
        addSubview(createButton)

        let skipButton = UIButton(frame: CGRect(x: 0, y: createButton.frame.size.height + createButton.frame.origin.y + 30, width: frame.size.width / 2, height: 40))
        skipButton.setTitle(NSLocalizedString("skip", comment: ""), for: .normal)
        skipButton.setTitleColor(.placeholderText, for: .normal)
        skipButton.backgroundColor = .clear
        skipButton.center = CGPoint(x: center.x, y: skipButton.center.y)
        skipButton.layer.cornerRadius = 5
        skipButton.layer.borderWidth = 1
        skipButton.layer.borderColor = UIColor.placeholderText.cgColor
        skipButton.addTarget(self, action: #selector(skipPressed), for: .touchUpInside)
        addSubview(skipButton)
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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
       textField.resignFirstResponder()
       return true
    }
}
