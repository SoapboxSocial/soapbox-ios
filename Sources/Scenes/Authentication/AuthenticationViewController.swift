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

protocol AuthenticationStepViewController where Self: UIViewController {
    var hasBackButton: Bool { get }

    var stepDescription: String? { get }
}

class AuthenticationViewController: UIPageViewController {
    var output: AuthenticationViewControllerOutput!

    private var orderedViewControllers = [AuthenticationStepViewController]()

    private var state = AuthenticationInteractor.AuthenticationState.start

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title3, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .body, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.backgroundColor = .lightBrandColor
        button.imageView?.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)

        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            backButton.widthAnchor.constraint(equalToConstant: 40),
        ])

        backButton.layer.cornerRadius = 20

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
        ])

        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            descriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            descriptionLabel.rightAnchor.constraint(equalTo: view.leftAnchor, constant: -20),
        ])

        let start = AuthenticationStartViewController()
        start.delegate = self
        orderedViewControllers.append(start)

        let email = AuthenticationEmailViewController()
        email.delegate = self
        orderedViewControllers.append(email)

        let pin = AuthenticationPinViewController()
        pin.delegate = self
        orderedViewControllers.append(pin)

        let name = AuthenticationNameViewController()
        name.delegate = self
        orderedViewControllers.append(name)

        let username = AuthenticationUsernameViewController()
        username.delegate = self
        orderedViewControllers.append(username)

        let follow = AuthenticationFollowViewController()
        follow.delegate = self
        orderedViewControllers.append(follow)

        setViewControllers([orderedViewControllers[0]], direction: .forward, animated: false)
    }

    @objc private func didTapBackButton() {
        transitionTo(state: AuthenticationInteractor.AuthenticationState(rawValue: state.rawValue - 1)!) // @TODO safe
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

        didSubmit(withText: pin)
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
                self.transitionTo(state: .start)
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

        let view = orderedViewControllers[state.rawValue]

        UIView.animate(withDuration: 0.3, animations: {
            if view.hasBackButton {
                self.backButton.isHidden = false
            } else {
                self.backButton.isHidden = true
            }

            self.titleLabel.text = view.title
            self.descriptionLabel.text = view.stepDescription
        })

        setViewControllers([view], direction: direction, animated: true)
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

extension AuthenticationViewController: AuthenticationTextInputViewControllerDelegate {
    func didSubmit(withText text: String?) {
        switch state {
        case .login:
            output.login(email: text)
        case .pin:
            output.submitPin(pin: text)
        default:
            return
        }
    }
}

extension AuthenticationViewController: AuthenticationFollowViewControllerDelegate {
    func didSubmit(users: [Int]) {
        output.follow(users: users)
    }
}
