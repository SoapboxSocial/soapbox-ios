import UIKit

class GroupCell: UICollectionViewCell {
    var name: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title3, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        contentView.backgroundColor = .foreground
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.cornerRadius = 56 / 2

        contentView.addSubview(name)

        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentView.heightAnchor.constraint(equalTo: heightAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor),
        ])

        NSLayoutConstraint.activate([
            name.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            name.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            name.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            name.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
