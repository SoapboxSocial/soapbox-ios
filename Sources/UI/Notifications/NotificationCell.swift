import UIKit

class NotificationCell: UICollectionViewCell {
    let image: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .brandColor
        image.layer.cornerRadius = 40 / 2
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    let name: UILabel = {
        let label = UILabel()
        label.font = .rounded(forTextStyle: .body, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var body: String!

    var time: Int!

    private var descriptionLabel: UILabel = {
        let description = UILabel()
        description.font = .rounded(forTextStyle: .body, weight: .regular)
        description.translatesAutoresizingMaskIntoConstraints = false
        return description
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(name)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(image)

        NSLayoutConstraint.activate([
            image.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            image.heightAnchor.constraint(equalToConstant: 40),
            image.widthAnchor.constraint(equalToConstant: 40),
        ])

        NSLayoutConstraint.activate([
            name.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 10),
            name.rightAnchor.constraint(equalTo: contentView.rightAnchor),
        ])

        NSLayoutConstraint.activate([
            descriptionLabel.leftAnchor.constraint(equalTo: name.leftAnchor),
            descriptionLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: name.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: name.topAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let label = NSMutableAttributedString(string: body ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.label])

        let interval = TimeInterval(time)
        label.append(
            NSAttributedString(
                string: " " + Date(timeIntervalSince1970: interval).timeAgoDisplay(),
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel]
            )
        )

        descriptionLabel.attributedText = label
    }
}
