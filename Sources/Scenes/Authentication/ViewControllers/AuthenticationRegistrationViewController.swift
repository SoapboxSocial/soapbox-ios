import UIKit

protocol AuthenticationRegistrationViewControllerDelegate {
    func didSubmit(username: String?, displayName: String?, image: UIImage?)
}

class AuthenticationRegistrationViewController: ViewControllerWithKeyboardConstraint {
    var delegate: AuthenticationRegistrationViewControllerDelegate?

    private let usernameTextField: TextField = {
        let textField = TextField(frame: .zero, theme: .light)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = NSLocalizedString("username", comment: "")
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }()

    private let displayNameTextField: TextField = {
        let textField = TextField(frame: .zero, theme: .light)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = NSLocalizedString("display_name", comment: "")
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }()

    private let submitButton: Button = {
        let button = Button(size: .large)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("submit", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(didSubmit), for: .touchUpInside)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        return button
    }()

    private var imageButton: EditImageButton!

    private var imagePicker = ImagePicker()

    private var image: UIImage?

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

        imageButton = EditImageButton()
        imageButton.addTarget(self, action: #selector(selectImage))

        view.addSubview(usernameTextField)
        view.addSubview(displayNameTextField)
        view.addSubview(submitButton)
        view.addSubview(imageButton)
        view.addSubview(label)

        imagePicker.delegate = self

        bottomLayoutConstraint = submitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(view.frame.size.height / 3))
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
    }

    @objc private func didSubmit() {
        delegate?.didSubmit(username: usernameTextField.text, displayName: displayNameTextField.text, image: image)
    }

    @objc private func selectImage() {
        imagePicker.present(self)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AuthenticationRegistrationViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        guard image != nil else { return }
        imageButton.image = image
        self.image = image
    }
}

extension AuthenticationRegistrationViewController: AuthenticationViewControllerWithInput {
    func enableSubmit() {
        submitButton.isEnabled = true
    }
}
