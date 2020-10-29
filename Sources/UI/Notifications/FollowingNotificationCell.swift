import UIKit

class FollowingNotificationCell: UICollectionViewCell {
    var user: Int!

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

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(name)

        let description = UILabel()
        description.text = NSLocalizedString("started_following_you", comment: "")
        description.font = .rounded(forTextStyle: .body, weight: .regular)
        description.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(description)

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
            description.leftAnchor.constraint(equalTo: name.leftAnchor),
            description.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            description.topAnchor.constraint(equalTo: name.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: description.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: name.topAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
