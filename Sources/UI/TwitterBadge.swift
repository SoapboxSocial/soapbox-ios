import UIKit

class TwitterBadge: Badge {
    private var icon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "twitter-blue"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Twitter"
        label.font = .rounded(forTextStyle: .body, weight: .semibold)
        label.textColor = .label
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(icon)
        addSubview(label)

        backgroundColor = .foreground

        NSLayoutConstraint.activate([
            icon.heightAnchor.constraint(equalToConstant: 24),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            icon.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            icon.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            label.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
