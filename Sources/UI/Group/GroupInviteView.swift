import UIKit

class GroupInviteView: UIView {
    var image: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 48 / 2
        view.backgroundColor = .lightBrandColor
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .rounded(forTextStyle: .title3, weight: .bold)
        label.textColor = .white
        return label
    }()

    var acceptButton: Button = {
        let button = Button(size: .small)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.setTitle(NSLocalizedString("accept", comment: ""), for: .normal)
        return button
    }()

    var declineButton: Button = {
        let button = Button(size: .small)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .lightBrandColor
        button.setTitleColor(.white, for: .normal)
        button.setTitle(NSLocalizedString("decline", comment: ""), for: .normal)
        return button
    }()

    init() {
        super.init(frame: .zero)

        layer.cornerRadius = 30
        backgroundColor = .brandColor
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(image)
        addSubview(label)

        addSubview(acceptButton)
        addSubview(declineButton)

        NSLayoutConstraint.activate([
            image.heightAnchor.constraint(equalToConstant: 48),
            image.widthAnchor.constraint(equalToConstant: 48),
            image.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            image.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: image.topAnchor),
            label.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 10),
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            label.bottomAnchor.constraint(greaterThanOrEqualTo: image.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            declineButton.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor, multiplier: 0.5, constant: -30),
            declineButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            declineButton.leftAnchor.constraint(equalTo: image.leftAnchor),
        ])

        NSLayoutConstraint.activate([
            acceptButton.topAnchor.constraint(equalTo: declineButton.topAnchor),
            acceptButton.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor, multiplier: 0.5, constant: -30),
            acceptButton.leftAnchor.constraint(equalTo: declineButton.rightAnchor, constant: 10),
            acceptButton.rightAnchor.constraint(equalTo: label.rightAnchor),
        ])

        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: declineButton.bottomAnchor, constant: 20),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
