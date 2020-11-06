import UIKit

class CreateGroupCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        contentView.backgroundColor = UIColor.brandColor.withAlphaComponent(0.5)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.cornerRadius = 40 / 2

        let image = UIImageView(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .brandColor
        contentView.addSubview(image)

        NSLayoutConstraint.activate([
            image.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 4),
            image.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -4),
            image.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            image.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
        ])

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            contentView.heightAnchor.constraint(equalToConstant: 40),
            contentView.widthAnchor.constraint(equalToConstant: 40),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
