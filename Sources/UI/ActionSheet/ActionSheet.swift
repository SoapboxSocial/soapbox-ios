import DrawerView
import UIKit

class ActionSheet {
    class Action {
        enum Style {
            case `default`, cancel, destructive
        }

        let title: String
        let style: Style
        let handler: ((Action) -> Void)?

        init(title: String, style: Style, handler: ((Action) -> Void)? = nil) {
            self.title = title
            self.style = style
            self.handler = handler
        }
    }

    private var actions = [Action]()

    /// A closure called before the alert is dismissed but only if done by own method and not manually
    @objc
    public var willDismissHandler: (() -> Void)?

    func add(action: Action) {
        actions.append(action)
    }

    func present(_ context: UIView? = nil) {
        var presenter: UIView
        if let view = context {
            presenter = view
        } else {
            presenter = UIApplication.shared.keyWindow!
        }

        let view = ActionSheetView(actions: actions)

        let drawer = DrawerView(withView: view)
        drawer.position = .closed
        drawer.delegate = self
        drawer.cornerRadius = 30.0
        drawer.backgroundEffect = nil
        drawer.snapPositions = [.closed, .open]
        drawer.enabled = false
        drawer.backgroundColor = .foreground
        drawer.openHeightBehavior = .fitting
        drawer.contentVisibilityBehavior = .allowPartial

//        presenter?.addSubview(drawer)

        view.autoPinEdgesToSuperview()
        drawer.attachTo(view: presenter)

        drawer.setPosition(.open, animated: true)
    }
}

extension ActionSheet: DrawerViewDelegate {
    func drawer(_ drawerView: DrawerView, didTransitionTo position: DrawerPosition) {
        if position == .closed {
            drawerView.removeFromSuperview()
        }
    }

    func drawer(_: DrawerView, willTransitionFrom _: DrawerPosition, to targetPosition: DrawerPosition) {
        if targetPosition == .closed {
            willDismissHandler?()
        }
    }
}

private class ActionSheetView: UIView {
    private var stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 0
        stack.distribution = .equalSpacing
        stack.alignment = .fill
        stack.axis = .vertical
        return stack
    }()

    init(actions: [ActionSheet.Action]) {
        super.init(frame: .zero)

        addSubview(stack)

        for action in actions {
            let actionView = ActionView(action: action)
            actionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
            stack.addArrangedSubview(actionView)
        }

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: stack.topAnchor, constant: -30),
            stack.leftAnchor.constraint(equalTo: leftAnchor),
            stack.rightAnchor.constraint(equalTo: rightAnchor),
            stack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])
    }

    @objc private func tap(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view as? ActionView else {
            return
        }

        guard let drawer = self.superview as? DrawerView else {
            fatalError("not in drawer")
        }

        drawer.setPosition(.closed, animated: true)

        if let handler = view.action.handler {
            handler(view.action)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class ActionView: UIView {
    let action: ActionSheet.Action

    private let seperator: UIView = {
        let view = UIView()
        view.backgroundColor = .quaternaryLabel
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .rounded(forTextStyle: .title3, weight: .bold)
        return label
    }()

    init(action: ActionSheet.Action) {
        self.action = action

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        addSubview(seperator)
        addSubview(label)

        switch action.style {
        case .cancel:
            label.textColor = .secondaryLabel
        case .destructive:
            label.textColor = .systemRed
        case .default:
            label.textColor = .label
        }

        NSLayoutConstraint.activate([
            seperator.leftAnchor.constraint(equalTo: leftAnchor),
            seperator.rightAnchor.constraint(equalTo: rightAnchor),
            seperator.topAnchor.constraint(equalTo: topAnchor),
            seperator.heightAnchor.constraint(equalToConstant: 1),
        ])

        label.text = action.title

        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: leftAnchor),
            label.rightAnchor.constraint(equalTo: rightAnchor),
            label.topAnchor.constraint(equalTo: seperator.bottomAnchor, constant: 15),
            bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 15),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
