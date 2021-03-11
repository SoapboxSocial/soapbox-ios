import DrawerView
import UIKit

class ActionSheet: UIViewController {
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

    /// A closure called before the alert is dismissed but only if done by own method and not manually
    @objc
    public var willDismissHandler: (() -> Void)?

    private var actions = [Action]()

    private let manager: DrawerPresentationManager = {
        let manager = DrawerPresentationManager()
        manager.drawer.openHeightBehavior = .fitting
        manager.drawer.backgroundColor = .foreground
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

    func add(action: Action) {
        actions.append(action)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        var last: ActionView?

        let handle = UIView()
        handle.translatesAutoresizingMaskIntoConstraints = false
        handle.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        handle.layer.cornerRadius = 2.5
        view.addSubview(handle)

        NSLayoutConstraint.activate([
            handle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handle.heightAnchor.constraint(equalToConstant: 5),
            handle.widthAnchor.constraint(equalToConstant: 36),
            handle.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
        ])

        for action in actions {
            let actionView = ActionView(action: action)
            actionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
            view.addSubview(actionView)

            NSLayoutConstraint.activate([
                actionView.leftAnchor.constraint(equalTo: view.leftAnchor),
                actionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            ])

            if last == nil {
                actionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
            } else {
                actionView.topAnchor.constraint(equalTo: last!.bottomAnchor).isActive = true
            }

            last = actionView
        }

        if last == nil {
            return
        }

        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spacer)

        NSLayoutConstraint.activate([
            spacer.topAnchor.constraint(equalTo: last!.bottomAnchor),
            spacer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    @objc private func tap(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view as? ActionView else {
            return
        }

        dismiss(animated: true)

        if let handler = view.action.handler {
            handler(view.action)
        }
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
