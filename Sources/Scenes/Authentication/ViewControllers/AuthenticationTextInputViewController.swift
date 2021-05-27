import UIKit

protocol AuthenticationTextInputViewControllerDelegate: AnyObject {
    func didSubmit(withText text: String?)
}

class AuthenticationTextInputViewController: ViewControllerWithKeyboardConstraint, AuthenticationStepViewController {
    weak var delegate: AuthenticationTextInputViewControllerDelegate?

    var stepDescription: String? {
        return nil
    }

    var hasBackButton: Bool {
        return false
    }

    let textField: TextField = {
        let textField = TextField(frame: .zero, theme: .light)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }()

    let submitButton: Button = {
        let button = Button(size: .large)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("next", comment: ""), for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        button.isEnabled = false
        button.addTarget(self, action: #selector(didSubmit), for: .touchUpInside)
        return button
    }()

    init() {
        super.init(nibName: nil, bundle: nil)

        view.addSubview(textField)
        view.addSubview(submitButton)

        bottomLayoutConstraint = submitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(view.frame.size.height / 3))
        bottomLayoutConstraint.isActive = true

        textField.delegate = self

        NSLayoutConstraint.activate([
            textField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            textField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 56),
            textField.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -10),
        ])

        NSLayoutConstraint.activate([
            submitButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            submitButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        textField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.endEditing(true)
    }

    func enableSubmit() {
        UIView.animate(withDuration: 0.3, animations: {
            self.submitButton.isEnabled = true
        })
    }

    @objc private func didSubmit() {
        UIView.animate(withDuration: 0.3, animations: {
            self.submitButton.isEnabled = false
        })

        delegate?.didSubmit(withText: textField.text)
    }
}

extension AuthenticationTextInputViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3, animations: {
            if textField.text != "" {
                self.submitButton.isEnabled = true
            } else {
                self.submitButton.isEnabled = false
            }
        })
    }
}
