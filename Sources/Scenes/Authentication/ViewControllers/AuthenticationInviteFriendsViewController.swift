import UIKit

class AuthenticationInviteFriendsViewController: UIViewController, AuthenticationStepViewController {
    var stepDescription: String? {
        return nil
    }

    var hasSkipButton: Bool {
        return true
    }

    var hasBackButton: Bool {
        return false
    }
}
