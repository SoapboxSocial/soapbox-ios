import UIKit

class AuthenticationNameViewController: AuthenticationTextInputViewController {
    override init() {
        super.init()

        // @TODO description
        title = NSLocalizedString("Authentication.Name", comment: "")
        textField.text = NSLocalizedString("Authentication.Name", comment: "")
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
