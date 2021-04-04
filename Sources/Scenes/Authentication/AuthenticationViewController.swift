import UIKit

protocol AuthenticationViewControllerWithInput {
    func enableSubmit()
}

protocol AuthenticationViewControllerOutput {
    func login(email: String?)
    func loginWithApple()
    func submitPin(pin: String?)
    func register(username: String?, displayName: String?, image: UIImage?)
    func follow(users: [Int])
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

        let follow = AuthenticationFollowViewController()
        follow.delegate = self
        orderedViewControllers.append(follow)

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
    func displayEmailRegistrationDisabledError() {
        if let controller = orderedViewControllers[state.rawValue] as? AuthenticationViewControllerWithInput {
            controller.enableSubmit()
        }

        let banner = NotificationBanner(title: NSLocalizedString("register_with_email_disabled_use_apple", comment: ""), style: .danger, type: .normal)
        banner.onTap = {
            DispatchQueue.main.async {
                self.transitionTo(state: .getStarted)
            }
        }

        banner.show()
    }

    func displayError(_ style: NotificationBanner.BannerType, title: String, description: String?) {
        if let controller = orderedViewControllers[state.rawValue] as? AuthenticationViewControllerWithInput {
            controller.enableSubmit()
        }

        let banner = NotificationBanner(title: title, subtitle: description, style: .danger, type: style)
        banner.show()
    }

    func transitionTo(state: AuthenticationInteractor.AuthenticationState) {
        var direction = UIPageViewController.NavigationDirection.forward
        if state.rawValue < self.state.rawValue {
            direction = .reverse
        }

        self.state = state

        setViewControllers([orderedViewControllers[state.rawValue]], direction: direction, animated: true)
    }
}

extension AuthenticationViewController: AuthenticationStartViewControllerDelegate {
    func didSubmit() {
        transitionTo(state: .login)
    }

    func didRequestSignInWithApple() {
        output.loginWithApple()
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

extension AuthenticationViewController: AuthenticationFollowViewControllerDelegate {
    func didSubmit(users: [Int]) {
        output.follow(users: users)
    }
}
