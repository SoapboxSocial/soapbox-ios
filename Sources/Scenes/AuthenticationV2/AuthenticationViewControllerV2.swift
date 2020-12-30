import UIKit

class AuthenticationViewControllerV2: UIPageViewController {
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)

        setViewControllers([AuthenticationEmailViewController()], direction: .forward, animated: false)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .brandColor
    }
}
