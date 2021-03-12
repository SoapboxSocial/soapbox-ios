import DrawerView
import UIKit

class DrawerViewController: UIViewController {
    let manager: DrawerPresentationManager = {
        let manager = DrawerPresentationManager()
        manager.drawer.backgroundEffect = nil
        manager.drawer.cornerRadius = 30
        return manager
    }()

    init() {
        super.init(nibName: nil, bundle: nil)

        transitioningDelegate = manager
        modalPresentationStyle = .custom
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
