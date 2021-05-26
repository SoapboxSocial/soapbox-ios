import AuthenticationServices
import UIKit

protocol AuthenticationStartViewControllerDelegate {
    func didSubmit()
    func didRequestSignInWithApple()
}

class AuthenticationStartViewController: UIViewController, AuthenticationStepViewController {
    var stepDescription: String? {
        return ""
    }

    var hasBackButton: Bool {
        return false
    }

    var delegate: AuthenticationStartViewControllerDelegate?

    private let terms: UITextView = {
        let text = UITextView()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.isScrollEnabled = false
        text.isEditable = false
        text.backgroundColor = .clear
        text.contentInset = .zero
        text.font = .rounded(forTextStyle: .subheadline, weight: .semibold)
        text.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
        ]

        return text
    }()

    private let submitButton: Button = {
        let button = Button(size: .large)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("continue_email", comment: ""), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(didSubmit), for: .touchUpInside)
        return button
    }()

    private let signInWithApple: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
        button.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loginWithApple), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(signInWithApple)
        view.addSubview(submitButton)

        terms.attributedText = termsNoticeAttributedString()
        terms.textAlignment = .center
        view.addSubview(terms)

        NSLayoutConstraint.activate([
            signInWithApple.heightAnchor.constraint(equalTo: submitButton.heightAnchor),
            signInWithApple.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            signInWithApple.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            signInWithApple.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -10),
        ])

        NSLayoutConstraint.activate([
            submitButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            submitButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            submitButton.bottomAnchor.constraint(equalTo: terms.topAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            terms.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            terms.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            terms.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }

    private func termsNoticeAttributedString() -> NSMutableAttributedString {
        let notice = NSLocalizedString("login_terms_notice", comment: "")
        let termsText = NSLocalizedString("terms", comment: "")
        let privacyText = NSLocalizedString("privacy", comment: "")

        let attributedString = NSMutableAttributedString(string: notice, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.6),
        ])

        attributedString.addAttributes(toText: termsText, [
            NSAttributedString.Key.link: URL(string: "https://soapbox.social/terms") as Any,
        ])

        attributedString.addAttributes(toText: privacyText, [
            NSAttributedString.Key.link: URL(string: "https://soapbox.social/privacy") as Any,
        ])

        return attributedString
    }

    @objc private func didSubmit() {
        delegate?.didSubmit()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let height = submitButton.frame.size.height
        let newFontHeight = height * 0.43

        guard let font = submitButton.titleLabel?.font else {
            return
        }

        if newFontHeight < font.pointSize {
            submitButton.titleLabel?.font = .rounded(withPointSize: newFontHeight, weight: .bold)
        }
    }
}

extension AuthenticationStartViewController: ASAuthorizationControllerDelegate {
    @objc private func loginWithApple() {
        delegate?.didRequestSignInWithApple()
    }
}
