import UIKit

class PermissionButton: UIButton {
    let emoji: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title1, weight: .semibold)
        return label
    }()

    let title: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .rounded(forTextStyle: .headline, weight: .semibold)
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .rounded(forTextStyle: .subheadline, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(emoji)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 0
        stack.distribution = .fill
        stack.alignment = .fill
        stack.axis = .vertical
        addSubview(stack)

        stack.addArrangedSubview(title)
        stack.addArrangedSubview(descriptionLabel)

        addSubview(stack)

        NSLayoutConstraint.activate([
            emoji.leftAnchor.constraint(equalTo: leftAnchor),
            emoji.centerYAnchor.constraint(equalTo: stack.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leftAnchor.constraint(equalTo: emoji.rightAnchor, constant: 20),
            stack.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AuthenticationPermissionsViewController: UIViewController, AuthenticationStepViewController {
    var hasBackButton: Bool {
        return false
    }

    var hasSkipButton: Bool {
        return true
    }

    var stepDescription: String? {
        return NSLocalizedString("Authentication.Permissions.Description", comment: "")
    }

    init() {
        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Authentication.Permissions", comment: "")

        let button = PermissionButton()
        button.title.text = "Microphone"
        button.emoji.text = "🎙"
        button.descriptionLabel.text = "So your friends can hear your beautiful voice."
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
