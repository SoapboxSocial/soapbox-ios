import DrawerView
import UIKit

// @TODO add handle

class DrawerViewController: UIViewController {
    let manager: DrawerPresentationManager = {
        let manager = DrawerPresentationManager()
        manager.drawer.backgroundEffect = .none
        manager.drawer.cornerRadius = 30
        return manager
    }()

    let handle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternaryLabel
        view.layer.cornerRadius = 2.5
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(handle)

        NSLayoutConstraint.activate([
            handle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handle.heightAnchor.constraint(equalToConstant: 5),
            handle.widthAnchor.constraint(equalToConstant: 36),
            handle.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
        ])
    }

    init() {
        super.init(nibName: nil, bundle: nil)

        transitioningDelegate = manager
        modalPresentationStyle = .custom
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
