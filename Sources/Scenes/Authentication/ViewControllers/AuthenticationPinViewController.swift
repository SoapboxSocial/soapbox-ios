import UIKit

protocol AuthenticationPinViewControllerDelegate {
    func didSubmit(pin: String?)
}

class AuthenticationPinViewController: AuthenticationTextInputViewController {
    override var hasBackButton: Bool {
        return true
    }

    var delegate: AuthenticationPinViewControllerDelegate?

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = NSLocalizedString("enter_your_pin_received_by_mail", comment: "")
        label.font = .rounded(forTextStyle: .title1, weight: .bold)
        return label
    }()

    private let note: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = NSLocalizedString("check_spam", comment: "")
        label.font = .rounded(forTextStyle: .subheadline, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    override init() {
        super.init()

        title = NSLocalizedString("Authentication.Pin", comment: "")

        textField.keyboardType = .numberPad
        textField.textContentType = .oneTimeCode

        view.addSubview(note)

        NSLayoutConstraint.activate([
            note.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            note.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            note.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -20),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.endEditing(true)
    }

    @objc private func didSubmit() {
        submitButton.isEnabled = false
        delegate?.didSubmit(pin: textField.text)
    }
}

extension AuthenticationPinViewController: AuthenticationViewControllerWithInput {
    func enableSubmit() {
        submitButton.isEnabled = true
    }
}
