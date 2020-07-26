//
//  LoginViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 27.07.20.
//

import UIKit

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
        textField.translatesAutoresizingMaskIntoConstraints = false
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
        //textField.resignFirstResponder()
    }
    
}
