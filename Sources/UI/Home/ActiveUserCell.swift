import UIKit

class ActiveUserCell: UICollectionViewCell {
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

    var displayName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title3, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    var username: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .callout, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private var active: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20 / 2
        view.layer.borderWidth = 4.0
        view.layer.borderColor = UIColor.foreground.cgColor
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        contentView.backgroundColor = .foreground
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.cornerRadius = 15

        contentView.addSubview(image)

        contentView.addSubview(displayName)
        contentView.addSubview(username)

        contentView.addSubview(active)

        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentView.heightAnchor.constraint(equalTo: heightAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor),
        ])

        NSLayoutConstraint.activate([
            active.heightAnchor.constraint(equalToConstant: 20),
            active.widthAnchor.constraint(equalToConstant: 20),
            active.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            active.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            image.heightAnchor.constraint(equalToConstant: 48),
            image.widthAnchor.constraint(equalToConstant: 48),
            image.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            image.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
        ])

        NSLayoutConstraint.activate([
            displayName.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 8),
            displayName.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            displayName.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            username.topAnchor.constraint(equalTo: displayName.bottomAnchor),
            username.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            username.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        active.layer.borderColor = UIColor.foreground.cgColor
    }
}
