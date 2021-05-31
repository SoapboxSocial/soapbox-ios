import UIKit

class PermissionButton: UIView {
    let emoji: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title1, weight: .semibold)
        return label
    }()

    let title: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .headline, weight: .semibold)
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .rounded(forTextStyle: .subheadline, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let checkmark: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .brandColor

        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.white.cgColor

        let image = UIImageView(image: UIImage(systemName: "checkmark"))
        image.tintColor = .brandColor
        image.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(image)

        NSLayoutConstraint.activate([
            image.leftAnchor.constraint(equalTo: view.leftAnchor),
            image.rightAnchor.constraint(equalTo: view.rightAnchor),
            image.topAnchor.constraint(equalTo: view.topAnchor),
            image.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        return view
    }()

    var isSelected: Bool = false {
        didSet {
            if isSelected {
                checkmark.backgroundColor = .white
            } else {
                checkmark.backgroundColor = .brandColor
            }
        }
    }

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(emoji)
        addSubview(checkmark)

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
            emoji.widthAnchor.constraint(equalTo: emoji.heightAnchor),
        ])

        NSLayoutConstraint.activate([
            checkmark.rightAnchor.constraint(equalTo: rightAnchor),
            checkmark.centerYAnchor.constraint(equalTo: stack.centerYAnchor),
            checkmark.widthAnchor.constraint(equalTo: emoji.heightAnchor),
            checkmark.heightAnchor.constraint(equalTo: emoji.heightAnchor),
        ])

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leftAnchor.constraint(equalTo: emoji.rightAnchor, constant: 20),
            stack.rightAnchor.constraint(equalTo: checkmark.rightAnchor, constant: -20),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        checkmark.layer.cornerRadius = checkmark.frame.size.width / 2
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

    private let microphoneButton: PermissionButton = {
        let button = PermissionButton()
        button.title.text = "Microphone"
        button.emoji.text = "🎙"
        button.descriptionLabel.text = "So your friends can hear your beautiful voice."
        return button
    }()

    private let notificationsButton: PermissionButton = {
        let button = PermissionButton()
        button.title.text = "Microphone"
        button.emoji.text = "🎙"
        button.descriptionLabel.text = "So your friends can hear your beautiful voice."
        return button
    }()

    init() {
        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("Authentication.Permissions", comment: "")

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 0
        stack.distribution = .fill
        stack.alignment = .fill
        stack.axis = .vertical
        view.addSubview(stack)

        microphoneButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(micPermissions)))

        stack.addArrangedSubview(microphoneButton)
        stack.addArrangedSubview(notificationsButton)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            stack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func micPermissions() {
        UIView.animate(withDuration: 0.3, animations: {
            self.microphoneButton.isSelected.toggle()
        })
    }
}
