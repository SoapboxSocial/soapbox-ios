import UIKit

class GroupSearchCell: UICollectionViewCell {
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

    var name: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title3, weight: .bold)
        label.textColor = .label
        return label
    }()

    var seperator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .background
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        contentView.backgroundColor = .foreground
        contentView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(seperator)
        contentView.addSubview(name)
        contentView.addSubview(image)

        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        NSLayoutConstraint.activate([
            image.heightAnchor.constraint(equalToConstant: 48),
            image.widthAnchor.constraint(equalToConstant: 48),
            image.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            image.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            image.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            name.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 20),
            name.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            name.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            seperator.heightAnchor.constraint(equalToConstant: 1),
            seperator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            seperator.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            seperator.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
