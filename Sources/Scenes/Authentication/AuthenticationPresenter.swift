import Foundation
import UIWindowTransitions

protocol AuthenticationPresenterOutput {
    func displayError(_ style: NotificationBanner.BannerType, title: String, description: String?)
    func transitionTo(state: AuthenticationInteractor.AuthenticationState)
    func displayEmailRegistrationDisabledError()
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
        case .invalidDisplayName:
            output.displayError(
                .normal,
                title: NSLocalizedString("Authentication.Error.InvalidDisplayName", comment: ""),
                description: nil
            )
        case .usernameTaken:
            output.displayError(.normal, title: NSLocalizedString("username_already_exists", comment: ""), description: nil)
        case .registerWithEmailDisabled:
            output.displayEmailRegistrationDisabledError()
        }
    }

    func present(state: AuthenticationInteractor.AuthenticationState) {
        output.transitionTo(state: state)

//        if state == .success {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
//                self.presentLoggedInView()
//            }
//        }
    }

    func presentLoggedInView() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window!.set(
            rootViewController: delegate.createLoggedIn(),
            options: UIWindow.TransitionOptions(direction: .fade, style: .easeOut)
        )
    }
}
