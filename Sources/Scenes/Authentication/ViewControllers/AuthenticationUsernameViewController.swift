import UIKit

class AuthenticationUsernameViewController: AuthenticationTextInputViewController {
    override var hasBackButton: Bool {
        return true
    }

    override init() {
        super.init()

        // @TODO description
        title = NSLocalizedString("Authentication.Username", comment: "")
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
