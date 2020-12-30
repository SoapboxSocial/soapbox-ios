import UIKit

class AuthenticationViewControllerV2: UIPageViewController {
    private var orderedViewControllers: [UIViewController] = [
        AuthenticationStartViewController(),
        AuthenticationEmailViewController(),
        AuthenticationPinViewController(),
        AuthenticationRegistrationViewController(),
    ]

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
