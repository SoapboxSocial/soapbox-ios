import UIKit

class CollectionViewCell: UICollectionViewCell {
    var image: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 48 / 2
        view.backgroundColor = .brandColor
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .body, weight: .semibold)
        label.textColor = .label
        return label
    }()

    var subtitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .body, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 0
        stack.distribution = .fill
        stack.alignment = .fill
        stack.axis = .vertical
        contentView.addSubview(stack)

        stack.addArrangedSubview(title)
        stack.addArrangedSubview(subtitle)

        contentView.addSubview(image)

        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        NSLayoutConstraint.activate([
            stack.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 20),
            stack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            image.heightAnchor.constraint(equalToConstant: 48),
            image.widthAnchor.constraint(equalToConstant: 48),
            image.topAnchor.constraint(equalTo: contentView.topAnchor),
            image.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            image.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}