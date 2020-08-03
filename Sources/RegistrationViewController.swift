//
//  RegistrationViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 03.08.20.
//

import UIKit

class RegistrationViewController: UIViewController {
    let token: String

    var username: UITextField!
    var displayName: UITextField!

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

        username = UITextField(frame: CGRect(x: 0, y: 100, width: view.frame.size.width / 2, height: 40))
        username.borderStyle = .roundedRect
        username.center = CGPoint(x: view.center.x, y: username.center.y)
        username.keyboardType = .numberPad
        username.returnKeyType = .next
        username.placeholder = "Username"
        username.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(username)

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        label.text = "Username"
        label.textAlignment = .center
        label.textColor = .white
        view.addSubview(label)
        label.center = CGPoint(x: view.center.x, y: username.frame.origin.y - 20)

        displayName = UITextField(frame: CGRect(x: 0, y: username.frame.origin.y + username.frame.size.height + 30, width: view.frame.size.width / 2, height: 40))
        displayName.borderStyle = .roundedRect
        displayName.center = CGPoint(x: view.center.x, y: displayName.center.y)
        displayName.keyboardType = .numberPad
        displayName.returnKeyType = .next
        displayName.placeholder = "Username"
        displayName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(displayName)

        let createButton = UIButton(frame: CGRect(x: 0, y: displayName.frame.size.height + displayName.frame.origin.y + 30, width: view.frame.size.width / 2, height: 40))
        createButton.setTitle(NSLocalizedString("create", comment: ""), for: .normal)
        createButton.center = CGPoint(x: view.center.x, y: createButton.center.y)
        createButton.layer.cornerRadius = 5
        createButton.layer.borderWidth = 1
        createButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        view.addSubview(createButton)
    }

    @objc private func submit() {
        APIClient().register(token: token, username: username.text!, displayName: displayName.text!) { _ in
        }
    }
}
