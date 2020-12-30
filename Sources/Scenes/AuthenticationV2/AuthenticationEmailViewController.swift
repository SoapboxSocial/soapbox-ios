import UIKit

class AuthenticationEmailViewController: ViewControllerWithKeyboardConstraint {
    private let textField: TextField = {
        let textField = TextField(frame: .zero, theme: .light)
        textField.placeholder = "Email"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .emailAddress
        textField.textContentType = .emailAddress
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }()

    private let terms: UITextView = {
        let text = UITextView()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.isScrollEnabled = false
        text.isEditable = false
        text.backgroundColor = .clear
        text.contentInset = .zero
        text.font = .rounded(forTextStyle: .caption1, weight: .regular)
        text.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
        ]

        return text
    }()

    private let submitButton: Button = {
        let button = Button(size: .large)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("next", comment: ""), for: .normal)
//        button.addTarget(self, action: #selector(didSubmit), for: .touchUpInside)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        return button
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = NSLocalizedString("email_login", comment: "")
        label.font = .rounded(forTextStyle: .title1, weight: .bold)
        return label
    }()

    private var isDisappearing = false

    init() {
        super.init(nibName: nil, bundle: nil)

        view.addSubview(label)

        terms.attributedText = termsNoticeAttributedString()
        view.addSubview(terms)

        view.addSubview(textField)
        view.addSubview(submitButton)

        textField.delegate = self

        bottomLayoutConstraint = submitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(view.frame.size.height / 4))
        bottomLayoutConstraint.isActive = true

        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            label.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            textField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            textField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 56),
            textField.bottomAnchor.constraint(equalTo: terms.topAnchor, constant: -10),
        ])

        NSLayoutConstraint.activate([
            terms.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            terms.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            terms.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            submitButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            submitButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        textField.becomeFirstResponder()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isDisappearing = true
        view.endEditing(true)
    }

    private func termsNoticeAttributedString() -> NSMutableAttributedString {
        let notice = NSLocalizedString("login_terms_notice", comment: "")
        let termsText = NSLocalizedString("terms", comment: "")
        let privacyText = NSLocalizedString("privacy", comment: "")

        let attributedString = NSMutableAttributedString(string: notice, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])

        let fontAttribute = UIFont.rounded(forTextStyle: .caption1, weight: .bold)

        attributedString.addAttributes(toText: termsText, [
            NSAttributedString.Key.font: fontAttribute,
            NSAttributedString.Key.link: URL(string: "https://soapbox.social/terms") as Any,
        ])

        attributedString.addAttributes(toText: privacyText, [
            NSAttributedString.Key.font: fontAttribute,
            NSAttributedString.Key.link: URL(string: "https://soapbox.social/privacy") as Any,
        ])

        return attributedString
    }
}

extension AuthenticationEmailViewController: UITextFieldDelegate {
    func textFieldShouldEndEditing(_: UITextField) -> Bool {
        if isDisappearing {
            return true
        }

        return false
    }
}
