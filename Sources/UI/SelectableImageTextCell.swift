import UIKit

class SelectableImageTextCell: UICollectionViewCell {
    var image: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .brandColor
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .body, weight: .regular)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    var selectedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.brandColor.withAlphaComponent(0.8)
        view.translatesAutoresizingMaskIntoConstraints = false

        let image = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .white
        view.addSubview(image)

        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            image.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            image.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            image.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        contentView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(title)
        contentView.addSubview(image)

        image.addSubview(selectedView)

        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        NSLayoutConstraint.activate([
            image.heightAnchor.constraint(equalToConstant: frame.size.width),
            image.widthAnchor.constraint(equalToConstant: frame.size.width),
            image.topAnchor.constraint(equalTo: contentView.topAnchor),
            image.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])

        NSLayoutConstraint.activate([
            selectedView.heightAnchor.constraint(equalTo: image.heightAnchor),
            selectedView.widthAnchor.constraint(equalTo: image.widthAnchor),
            selectedView.topAnchor.constraint(equalTo: image.topAnchor),
            selectedView.centerXAnchor.constraint(equalTo: image.centerXAnchor),
        ])

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 4),
            title.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            title.rightAnchor.constraint(equalTo: contentView.rightAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        image.layer.cornerRadius = frame.width / 2
        selectedView.layer.cornerRadius = frame.width / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        image.image = nil
        title.text = ""
    }
}
