import UIKit

class AuthenticationRegistrationViewController: ViewControllerWithKeyboardConstraint {
    private let usernameTextField: TextField = {
        let textField = TextField(frame: .zero, theme: .light)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = NSLocalizedString("username", comment: "")
//        textField.delegate = self
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }()

    private let displayNameTextField: TextField = {
        let textField = TextField(frame: .zero, theme: .light)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = NSLocalizedString("display_name", comment: "")
//        textField.delegate = self
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }()

    private let submitButton: Button = {
        let button = Button(size: .large)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("submit", comment: ""), for: .normal)
//        button.addTarget(self, action: #selector(didSubmit), for: .touchUpInside)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        return button
    }()

    private let imageButton: EditImageButton = {
        let button = EditImageButton()
//        imageView.addTarget(self, action: #selector(selectImage))
//        imageView.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + user.image))
        return button
    }()

    private var imagePicker = ImagePicker()

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = NSLocalizedString("create_account", comment: "")
        label.font = .rounded(forTextStyle: .title1, weight: .bold)
        return label
    }()

    init() {
        super.init(nibName: nil, bundle: nil)

        view.addSubview(usernameTextField)
        view.addSubview(displayNameTextField)
        view.addSubview(submitButton)
        view.addSubview(imageButton)
        view.addSubview(label)

        usernameTextField.delegate = self

        bottomLayoutConstraint = submitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(view.frame.size.height / 4))
        bottomLayoutConstraint.isActive = true

        NSLayoutConstraint.activate([
            imageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageButton.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -40),
            imageButton.heightAnchor.constraint(equalToConstant: 80),
            imageButton.widthAnchor.constraint(equalToConstant: 80),
        ])

        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            label.bottomAnchor.constraint(equalTo: usernameTextField.topAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            usernameTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            usernameTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            usernameTextField.heightAnchor.constraint(equalToConstant: 56),
            usernameTextField.bottomAnchor.constraint(equalTo: displayNameTextField.topAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            displayNameTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            displayNameTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            displayNameTextField.heightAnchor.constraint(equalToConstant: 56),
            displayNameTextField.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            submitButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            submitButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        usernameTextField.becomeFirstResponder()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    func beginEditing() {
//        textField.becomeFirstResponder()
//    }
}

extension AuthenticationRegistrationViewController: UITextFieldDelegate {
    func textFieldShouldEndEditing(_: UITextField) -> Bool {
        return false
    }
}
