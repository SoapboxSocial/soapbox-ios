import UIKit

class CreateStoryCell: UICollectionViewCell {
    private var image: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.brandColor.withAlphaComponent(0.5)
        view.clipsToBounds = true
        view.layer.cornerRadius = 48 / 2
        view.layer.masksToBounds = true

        let image = UIImageView(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 33, weight: .semibold)))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .brandColor
        view.addSubview(image)

        NSLayoutConstraint.activate([
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        contentView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(image)

        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            image.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            image.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            image.heightAnchor.constraint(equalTo: image.widthAnchor),
            image.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
