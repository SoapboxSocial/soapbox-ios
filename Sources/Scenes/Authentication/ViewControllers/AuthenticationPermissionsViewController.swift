import UIKit

class AuthenticationPermissionsViewController: UIViewController, AuthenticationStepViewController {
    var hasBackButton: Bool {
        return false
    }

    var hasSkipButton: Bool {
        return true
    }

    var stepDescription: String? {
        return NSLocalizedString("Authentication.Permissions.Description", comment: "")
    }

    init() {
        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Authentication.Permissions", comment: "")
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
