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

        backgroundColor = .foreground

        contentView.addSubview(label)
        contentView.addSubview(image)

        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: 40),
            image.heightAnchor.constraint(equalToConstant: 40),
            image.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            image.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 10),
            label.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            label.topAnchor.constraint(equalTo: image.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setText(name: String, body: String, time _: Int) {
        let content = NSMutableAttributedString(string: name + "\n", attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.label,
            NSAttributedString.Key.font: UIFont.rounded(forTextStyle: .body, weight: .semibold),
        ])

        content.append(NSAttributedString(string: body, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel,
            NSAttributedString.Key.font: UIFont.rounded(forTextStyle: .body, weight: .regular),
        ]))

        label.attributedText = content
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        image.image = nil
        label.text = ""
    }
}
