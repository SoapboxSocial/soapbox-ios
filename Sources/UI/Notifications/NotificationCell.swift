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

    private var label: UILabel = {
        let description = UILabel()
        description.textColor = .red
        description.font = .rounded(forTextStyle: .body, weight: .regular)
        description.translatesAutoresizingMaskIntoConstraints = false
        description.numberOfLines = 0
        return description
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(label)
        contentView.addSubview(image)

        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: 40),
            image.heightAnchor.constraint(equalToConstant: 40),
            image.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            image.topAnchor.constraint(equalTo: contentView.topAnchor),
        ])

        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 10),
            label.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setText(name: String, body: String, time: Int) {
        let content = NSMutableAttributedString(string: name + "\n", attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.label,
            NSAttributedString.Key.font: UIFont.rounded(forTextStyle: .body, weight: .bold),
        ])

        content.append(NSAttributedString(string: body, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.label,
            NSAttributedString.Key.font: UIFont.rounded(forTextStyle: .body, weight: .regular),
        ]))

        let interval = TimeInterval(time)
        content.append(
            NSAttributedString(
                string: " " + Date(timeIntervalSince1970: interval).timeAgoDisplay(),
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel]
            )
        )

        label.attributedText = content
    }
}
