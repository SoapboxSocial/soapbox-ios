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

    init() {
        super.init(frame: .zero)

        layer.cornerRadius = 30
        backgroundColor = .brandColor
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(image)
        addSubview(label)

        NSLayoutConstraint.activate([
            image.heightAnchor.constraint(equalToConstant: 48),
            image.widthAnchor.constraint(equalToConstant: 48),
            image.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            image.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: image.topAnchor),
            label.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 10),
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: 20),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
