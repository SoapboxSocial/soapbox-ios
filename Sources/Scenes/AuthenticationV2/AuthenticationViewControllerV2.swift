import NotificationBannerSwift
import UIKit

class AuthenticationViewControllerV2: UIPageViewController {
    private var orderedViewControllers: [UIViewController] = [
        AuthenticationStartViewController(),
        AuthenticationEmailViewController(),
        AuthenticationPinViewController(),
        AuthenticationRegistrationViewController(),
    ]

    private var state = AuthenticationInteractor.AuthenticationState.getStarted

    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .brandColor

        setViewControllers([orderedViewControllers[0]], direction: .forward, animated: true)
    }
}

extension AuthenticationViewControllerV2: AuthenticationPresenterOutput {
    func displayError(_ style: ErrorStyle, title: String, description: String?) {
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

//        self.state = state
//        submitButton.isEnabled = true
//        scrollView.setContentOffset(CGPoint(x: view.frame.size.width * CGFloat(state.rawValue), y: 0), animated: true)
//
//        if state == .requestNotifications {
//            UIView.animate(withDuration: 0.3) {
//                self.submitButton.frame = CGRect(origin: CGPoint(x: self.submitButton.frame.origin.x, y: self.view.frame.size.height), size: self.submitButton.frame.size)
//            }
//        }
//
//        if state == .success {
//            let confettiView = SwiftConfettiView(frame: view.bounds)
//            view.addSubview(confettiView)
//            confettiView.startConfetti()
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                confettiView.stopConfetti()
//            }
//        }
    }

    func display(profileImage _: UIImage) {}

    func displayImagePicker() {}
}
