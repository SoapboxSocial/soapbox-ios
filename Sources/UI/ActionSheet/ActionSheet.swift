import DrawerView
import UIKit

class ActionSheet: DrawerViewController {
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

    private let feedbackGenerator: UIImpactFeedbackGenerator = {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        return generator
    }()

    private let image: RoundedImageView = {
        let image = RoundedImageView()
        image.tintColor = .brandColor
        return image
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .rounded(forTextStyle: .title2, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let stack: UIStackView = {
        let view = UIStackView()
        view.alignment = .fill
        view.distribution = .fill
        view.axis = .vertical
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isLayoutMarginsRelativeArrangement = true
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        return view
    }()

    init(title: String? = nil, image: UIImage? = nil) {
        super.init()

        titleLabel.text = title
        self.image.image = image

        manager.drawer.openHeightBehavior = .fitting
        manager.drawer.backgroundColor = .foreground
        manager.presentationDelegate = self
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

        view.addSubview(stack)

        let imageContainer = UIView()
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.addSubview(image)

        stack.addArrangedSubview(imageContainer)

        if image.image == nil {
            imageContainer.isHidden = true
        }

        NSLayoutConstraint.activate([
            image.heightAnchor.constraint(equalToConstant: 40),
            image.widthAnchor.constraint(equalToConstant: 40),
            image.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor),
        ])

        NSLayoutConstraint.activate([
            imageContainer.heightAnchor.constraint(equalToConstant: 40),
        ])

        stack.addArrangedSubview(titleLabel)

        let actionsView = UIView()
        actionsView.translatesAutoresizingMaskIntoConstraints = false

        for action in actions {
            let actionView = ActionView(action: action)
            actionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
            actionsView.addSubview(actionView)

            NSLayoutConstraint.activate([
                actionView.leftAnchor.constraint(equalTo: actionsView.leftAnchor),
                actionView.rightAnchor.constraint(equalTo: actionsView.rightAnchor),
            ])

            if last == nil {
                actionView.topAnchor.constraint(equalTo: actionsView.topAnchor).isActive = true
            } else {
                actionView.topAnchor.constraint(equalTo: last!.bottomAnchor).isActive = true
            }

            last = actionView
        }

        stack.addArrangedSubview(actionsView)

        NSLayoutConstraint.activate([
            actionsView.bottomAnchor.constraint(equalTo: last!.bottomAnchor),
            actionsView.leftAnchor.constraint(equalTo: view.leftAnchor),
            actionsView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])

        if last == nil {
            return
        }

        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spacer)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: handle.bottomAnchor, constant: 32),
            stack.bottomAnchor.constraint(equalTo: spacer.topAnchor),
        ])

        NSLayoutConstraint.activate([
            spacer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        willDismissHandler?()
    }

    @objc private func tap(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view as? ActionView else {
            return
        }

        dismiss(animated: true, completion: {
            if let handler = view.action.handler {
                handler(view.action)
            }
        })
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
        label.numberOfLines = 0
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
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            heightAnchor.constraint(equalToConstant: 64),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ActionSheet: DrawerPresentationDelegate {
    func drawerPresentationWillBegin() {
        feedbackGenerator.impactOccurred()
    }
}
