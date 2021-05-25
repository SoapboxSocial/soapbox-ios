import UIKit

protocol AuthenticationEmailViewControllerDelegate {
    func didSubmit(email: String?)
}

class AuthenticationEmailViewController: AuthenticationTextInputViewController {
    var delegate: AuthenticationEmailViewControllerDelegate?

    override var hasBackButton: Bool {
        return true
    }

    override init() {
        super.init()

        title = NSLocalizedString("Authentication.Email", comment: "")
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
        delegate?.didSubmit(email: textField.text)
    }
}

extension AuthenticationEmailViewController: AuthenticationViewControllerWithInput {
    func enableSubmit() {
        submitButton.isEnabled = true
    }
}
