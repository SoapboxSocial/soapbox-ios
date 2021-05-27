import UIKit

class AuthenticationPinViewController: AuthenticationTextInputViewController {
    override var stepDescription: String? {
        return NSLocalizedString("Authentication.Pin.Description", comment: "")
    }

    override var hasBackButton: Bool {
        return true
    }

    override init() {
        super.init()

        title = NSLocalizedString("Authentication.Pin", comment: "")

        textField.keyboardType = .numberPad
        textField.textContentType = .oneTimeCode
        textField.placeholder = NSLocalizedString("Authentication.Pin", comment: "")
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.endEditing(true)
    }
}
