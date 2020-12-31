import UIKit

protocol AuthenticationStartViewControllerDelegate {
    func didSubmit()
}

class AuthenticationStartViewController: UIViewController {
    var delegate: AuthenticationStartViewControllerDelegate?

    private let terms: UITextView = {
        let text = UITextView()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.isScrollEnabled = false
        text.isEditable = false
        text.backgroundColor = .clear
        text.contentInset = .zero
        text.font = .rounded(forTextStyle: .caption1, weight: .medium)
        text.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
        ]

        return text
    }()

    private let submitButton: Button = {
        let button = Button(size: .large)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("get_started", comment: ""), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(didSubmit), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let logo = UIImageView(image: UIImage(named: "soapbar"))
        logo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logo)

        let logoPlaceholder = UIView()
        logoPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoPlaceholder)

        let greenDude = UIImageView(image: UIImage(named: "greendude"))
        greenDude.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(greenDude)

        let blueDude = UIImageView(image: UIImage(named: "bluedude"))
        blueDude.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blueDude)

        let pinkDude = UIImageView(image: UIImage(named: "pinkdude"))
        pinkDude.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pinkDude)

        view.addSubview(submitButton)

        terms.attributedText = termsNoticeAttributedString()
        terms.textAlignment = .center
        view.addSubview(terms)

        NSLayoutConstraint.activate([
            greenDude.leftAnchor.constraint(equalTo: view.leftAnchor),
            greenDude.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            blueDude.rightAnchor.constraint(equalTo: view.rightAnchor),
            blueDude.bottomAnchor.constraint(equalTo: greenDude.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            pinkDude.leftAnchor.constraint(equalTo: view.leftAnchor),
            pinkDude.topAnchor.constraint(equalTo: view.topAnchor),
        ])

        NSLayoutConstraint.activate([
            logoPlaceholder.leftAnchor.constraint(equalTo: view.leftAnchor),
            logoPlaceholder.rightAnchor.constraint(equalTo: view.rightAnchor),
            logoPlaceholder.topAnchor.constraint(equalTo: pinkDude.bottomAnchor),
            logoPlaceholder.bottomAnchor.constraint(equalTo: blueDude.topAnchor),
        ])

        NSLayoutConstraint.activate([
            logo.centerXAnchor.constraint(equalTo: logoPlaceholder.centerXAnchor),
            logo.centerYAnchor.constraint(equalTo: logoPlaceholder.centerYAnchor),
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
}
