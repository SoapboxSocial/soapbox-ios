import UIKit

class PermissionButton: UIButton {
    let emoji: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = false
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title1, weight: .semibold)
        return label
    }()

    let title: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = false
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .headline, weight: .semibold)
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = false
        label.textColor = .white
        label.font = .rounded(forTextStyle: .subheadline, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let checkmark: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .brandColor

        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.white.cgColor

        let image = UIImageView(image: UIImage(
            systemName: "checkmark",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .heavy)
        ))
        image.tintColor = .brandColor
        image.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(image)

        NSLayoutConstraint.activate([
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            image.heightAnchor.constraint(equalToConstant: 20),
            image.widthAnchor.constraint(equalToConstant: 20),
        ])

        return view
    }()

    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.3, animations: {
                if self.isSelected {
                    self.checkmark.backgroundColor = .white
                } else {
                    self.checkmark.backgroundColor = .brandColor
                }
            })
        }
    }

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(emoji)
        addSubview(checkmark)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 5
        stack.distribution = .fill
        stack.alignment = .fill
        stack.axis = .vertical
        stack.isUserInteractionEnabled = false
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
            checkmark.widthAnchor.constraint(equalToConstant: 32),
            checkmark.heightAnchor.constraint(equalToConstant: 32),
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
