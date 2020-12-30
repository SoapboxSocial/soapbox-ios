import UIKit

protocol AuthenticationSubController {
    func beginEditing()
}

class AuthenticationViewControllerV2: UIPageViewController {
    override var disablesAutomaticKeyboardDismissal: Bool { return true }

    private var orderedViewControllers: [UIViewController] = [
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [self] in
            setViewControllers([orderedViewControllers[2]], direction: .forward, animated: true)
        }
    }
}
