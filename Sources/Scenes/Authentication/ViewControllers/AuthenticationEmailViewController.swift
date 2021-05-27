import UIKit

class AuthenticationEmailViewController: AuthenticationTextInputViewController {
    override var hasBackButton: Bool {
        return true
    }

    override init() {
        super.init()

        title = NSLocalizedString("Authentication.Email", comment: "")

        textField.keyboardType = .emailAddress
        textField.textContentType = .emailAddress
        textField.placeholder = NSLocalizedString("Authentication.Email", comment: "")
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.endEditing(true)
    }
}
