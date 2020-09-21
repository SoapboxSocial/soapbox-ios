import UIKit

class UserCellV2: UICollectionViewCell {
    var image: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 48 / 2
        view.backgroundColor = .brandColor
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var displayName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title3, weight: .bold)
        label.textColor = .label
        return label
    }()

    var username: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title3, weight: .regular)
        label.textColor = .label
        return label
    }()

    private var userView: UIView = {
        let view = UIView()
        view.backgroundColor = .foreground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 30
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width).isActive = true

        addSubview(userView)

        NSLayoutConstraint.activate([
            userView.topAnchor.constraint(equalTo: topAnchor, constant: 10), // @TODO THIS SEEMS TO BE TOO BIG?
            userView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            userView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            userView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        userView.addSubview(displayName)
        userView.addSubview(username)
        userView.addSubview(image)

        NSLayoutConstraint.activate([
            image.heightAnchor.constraint(equalToConstant: 48),
            image.widthAnchor.constraint(equalToConstant: 48),
            image.topAnchor.constraint(equalTo: userView.topAnchor, constant: 20),
            image.leftAnchor.constraint(equalTo: userView.leftAnchor, constant: 20),
            image.bottomAnchor.constraint(equalTo: userView.bottomAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            displayName.topAnchor.constraint(equalTo: userView.topAnchor, constant: 20),
            displayName.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 20),
            displayName.rightAnchor.constraint(equalTo: userView.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            username.topAnchor.constraint(equalTo: displayName.bottomAnchor),
            username.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 20),
            username.rightAnchor.constraint(equalTo: userView.rightAnchor, constant: -20),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
