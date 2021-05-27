import UIKit

class AuthenticationUsernameViewController: AuthenticationTextInputViewController {
    override var stepDescription: String? {
        return NSLocalizedString("Authentication.Username.Description", comment: "")
    }

    override var hasBackButton: Bool {
        return true
    }

    override init() {
        super.init()

        title = NSLocalizedString("Authentication.Username", comment: "")
        textField.placeholder = NSLocalizedString("Authentication.Username", comment: "")
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
