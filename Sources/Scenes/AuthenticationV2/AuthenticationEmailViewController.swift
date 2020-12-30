import UIKit

class AuthenticationEmailViewController: UIViewController {
    private let emailTextField: TextField = {
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

    private var bottomLayoutConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        terms.attributedText = termsNoticeAttributedString()
        view.addSubview(terms)

        view.addSubview(emailTextField)

        bottomLayoutConstraint = terms.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomLayoutConstraint.isActive = true

        NSLayoutConstraint.activate([
            emailTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            emailTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 56),
            emailTextField.bottomAnchor.constraint(equalTo: terms.topAnchor, constant: -10),
        ])

        NSLayoutConstraint.activate([
            terms.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            terms.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        emailTextField.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrameNotification),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func keyboardWillChangeFrameNotification(notification: NSNotification) {
        let n = KeyboardNotification(notification)
        let keyboardFrame = n.frameEndForView(view: view)

        let viewFrame = view.frame
        let newBottomOffset = viewFrame.maxY - keyboardFrame.minY

        bottomLayoutConstraint.constant = -(newBottomOffset + 20)
        view.layoutIfNeeded()
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
