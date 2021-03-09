import DrawerView
import UIKit

class ActionSheet {
    private var view: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 0
        stack.distribution = .equalSpacing
        stack.alignment = .fill
        stack.axis = .vertical
        return stack
    }()

    func add(action: ActionSheetActionView) {
        stack.addArrangedSubview(action)
    }

    func present(_ context: UIView) {
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: stack.topAnchor, constant: -30),
            stack.leftAnchor.constraint(equalTo: view.leftAnchor),
            stack.rightAnchor.constraint(equalTo: view.rightAnchor),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        let drawer = DrawerView(withView: view)
        drawer.cornerRadius = 30.0
        drawer.backgroundEffect = nil
        drawer.snapPositions = [.closed, .open]
        drawer.enabled = false
        drawer.backgroundColor = .foreground
        drawer.openHeightBehavior = .fitting
        drawer.insetAdjustmentBehavior = .never
        drawer.contentVisibilityBehavior = .allowPartial

        drawer.attachTo(view: context)

        view.autoPinEdgesToSuperview()

        drawer.setPosition(.closed, animated: false)
        drawer.setPosition(.open, animated: true)
    }
}
