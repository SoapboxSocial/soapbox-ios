import UIKit

class AuthenticationNameViewController: AuthenticationTextInputViewController {
    override var stepDescription: String? {
        return NSLocalizedString("Authentication.Name.Description", comment: "")
    }

    override init() {
        super.init()

        title = NSLocalizedString("Authentication.Name", comment: "")
        textField.text = NSLocalizedString("Authentication.Name", comment: "")
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
