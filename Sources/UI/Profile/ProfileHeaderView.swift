import FocusableImageView
import UIKit

class ProfileHeaderView: UIView {
    var image: FocusableImageView = {
        let image = FocusableImageView()
        image.backgroundColor = .brandColor
        image.layer.cornerRadius = 96 / 2
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .rounded(forTextStyle: .title1, weight: .bold)
        return label
    }()

    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title3, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    var button: Button = {
        let button = Button(size: .small)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()

    var stack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 10
        view.distribution = .fill
        view.alignment = .fill
        view.axis = .vertical
        return view
    }()

    init() {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        addSubview(image)
        addSubview(button)

        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            image.widthAnchor.constraint(equalToConstant: 96),
            image.heightAnchor.constraint(equalToConstant: 96),
        ])

        addSubview(stack)

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            stack.leftAnchor.constraint(equalTo: leftAnchor),
            stack.rightAnchor.constraint(equalTo: rightAnchor),
            stack.bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor),
            stack.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: image.bottomAnchor),
            button.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        NSLayoutConstraint.activate([
            descriptionLabel.leftAnchor.constraint(equalTo: leftAnchor),
            descriptionLabel.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
