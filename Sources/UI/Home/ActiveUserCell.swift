import UIKit

class ActiveUserCell: UICollectionViewCell {
    var image: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 64 / 2
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
        label.font = .rounded(forTextStyle: .body, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private var active: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20 / 2
        view.layer.borderWidth = 4.0
        view.layer.borderColor = UIColor.background.cgColor

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        contentView.backgroundColor = .clear
        contentView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(image)
        contentView.addSubview(displayName)
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
            active.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            active.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 4),
        ])

        NSLayoutConstraint.activate([
            image.heightAnchor.constraint(equalToConstant: 64),
            image.widthAnchor.constraint(equalToConstant: 64),
            image.topAnchor.constraint(equalTo: contentView.topAnchor),
            image.leftAnchor.constraint(equalTo: contentView.leftAnchor),
        ])

        NSLayoutConstraint.activate([
            displayName.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 8),
            displayName.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            displayName.rightAnchor.constraint(equalTo: contentView.rightAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        active.layer.borderColor = UIColor.background.cgColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        image.image = nil
        displayName.text = ""
    }
}
