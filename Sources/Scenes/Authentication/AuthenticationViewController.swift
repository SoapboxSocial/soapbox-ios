import NotificationBannerSwift
import UIKit

protocol AuthenticationViewControllerWithInput {
    func enableSubmit()
}

protocol AuthenticationViewControllerOutput {
    func login(email: String?)
    func submitPin(pin: String?)
    func register(username: String?, displayName: String?, image: UIImage?)
}

class AuthenticationViewController: UIPageViewController {
    var output: AuthenticationViewControllerOutput!

    private var orderedViewControllers = [UIViewController]()

    private var state = AuthenticationInteractor.AuthenticationState.getStarted

    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)

        let start = AuthenticationStartViewController()
        start.delegate = self
        orderedViewControllers.append(start)

        let email = AuthenticationEmailViewController()
        email.delegate = self
        orderedViewControllers.append(email)

        let pin = AuthenticationPinViewController()
        pin.delegate = self
        orderedViewControllers.append(pin)

        let registration = AuthenticationRegistrationViewController()
        registration.delegate = self
        orderedViewControllers.append(registration)

        orderedViewControllers.append(AuthenticationRequestNotificationsViewController())
        orderedViewControllers.append(AuthenticationSuccessViewController())

        setViewControllers([orderedViewControllers[0]], direction: .forward, animated: false)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .brandColor
    }

    func inject(pin: String) -> Bool {
        if state != .pin {
            return false
        }

        didSubmit(pin: pin)
        return true
    }
}

extension AuthenticationViewController: AuthenticationPresenterOutput {
    func displayError(_ style: ErrorStyle, title: String, description: String?) {
        if let controller = orderedViewControllers[state.rawValue] as? AuthenticationViewControllerWithInput {
            controller.enableSubmit()
        }

        switch style {
        case .normal:
            let banner = NotificationBanner(title: title, subtitle: description, style: .danger)
            banner.show()
        case .floating:
            let banner = FloatingNotificationBanner(title: title, subtitle: description, style: .danger)
            banner.show(cornerRadius: 10, shadowBlurRadius: 15)
        }
    }

    func transitionTo(state: AuthenticationInteractor.AuthenticationState) {
        self.state = state

        setViewControllers([orderedViewControllers[state.rawValue]], direction: .forward, animated: true)
    }
}

extension AuthenticationViewController: AuthenticationStartViewControllerDelegate {
    func didSubmit() {
        transitionTo(state: .login)
    }
}

extension AuthenticationViewController: AuthenticationEmailViewControllerDelegate {
    func didSubmit(email: String?) {
        output.login(email: email)
    }
}

extension AuthenticationViewController: AuthenticationPinViewControllerDelegate {
    func didSubmit(pin: String?) {
        output.submitPin(pin: pin)
    }
}

extension AuthenticationViewController: AuthenticationRegistrationViewControllerDelegate {
    func didSubmit(username: String?, displayName: String?, image: UIImage?) {
        output.register(username: username, displayName: displayName, image: image)
    }
}
