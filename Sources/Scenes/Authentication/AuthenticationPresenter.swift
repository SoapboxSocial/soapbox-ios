import Foundation
import UIWindowTransitions

enum ErrorStyle {
    case normal, floating
}

protocol AuthenticationPresenterOutput {
    func displayError(_ style: ErrorStyle, title: String, description: String?)
    func transitionTo(state: AuthenticationInteractor.AuthenticationState)
}

class AuthenticationPresenter: AuthenticationInteractorOutput {
    let output: AuthenticationPresenterOutput

    init(output: AuthenticationPresenterOutput) {
        self.output = output
    }

    func present(error: AuthenticationInteractor.AuthenticationError) {
        switch error {
        case .general:
            output.displayError(
                .floating,
                title: NSLocalizedString("something_went_wrong", comment: ""),
                description: NSLocalizedString("please_try_again_later", comment: "")
            )
        case .invalidEmail:
            output.displayError(.normal, title: NSLocalizedString("invalid_email", comment: ""), description: nil)
        case .invalidPin:
            output.displayError(.normal, title: NSLocalizedString("incorrect_pin", comment: ""), description: nil)
        case .invalidUsername:
            output.displayError(.normal, title: NSLocalizedString("invalid_username", comment: ""), description: nil)
        case .missingProfileImage:
            output.displayError(.normal, title: NSLocalizedString("pick_profile_image", comment: ""), description: nil)
        case .usernameTaken:
            output.displayError(.normal, title: NSLocalizedString("username_already_exists", comment: ""), description: nil)
        }
    }

    func present(state: AuthenticationInteractor.AuthenticationState) {
        output.transitionTo(state: state)

        if state == .success {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                self.presentLoggedInView()
            }
        }
    }

    func presentLoggedInView() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window!.set(
            rootViewController: delegate.createLoggedIn(),
            options: UIWindow.TransitionOptions(direction: .fade, style: .easeOut)
        )
    }
}
