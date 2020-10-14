import UIKit

class RoomCell: UICollectionViewCell {
    enum RoomStyle {
        case normal, current
    }

    var style: RoomStyle = .normal {
        didSet {
            switch style {
            case .normal:
                contentView.backgroundColor = .foreground
                badge.style = .normal
                title.textColor = .label
            case .current:
                badge.style = .current
                contentView.backgroundColor = .brandColor
                title.textColor = .white
            }

            createImageViews()
        }
    }

    var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title2, weight: .bold)
        label.textColor = .label
        return label
    }()

    var members = [RoomState.RoomMember]() {
        didSet {
            createImageViews()
        }
    }

    private var badge: RoomBadge = {
        let badge = RoomBadge(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        badge.translatesAutoresizingMaskIntoConstraints = false
        return badge
    }()

    private var imageViews = [UIView]()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width).isActive = true

        contentView.backgroundColor = .foreground
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.cornerRadius = 30

        contentView.addSubview(title)
        contentView.addSubview(badge)

        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 10), // @TODO THIS SEEMS TO BE TOO BIG?
            contentView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            contentView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            title.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            title.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            badge.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20),
            badge.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            badge.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createImageViews() {
        imageViews.forEach { $0.removeFromSuperview() }

        var previousView = contentView

        // @todo only use members with images
        let count = members.count

        for i in 0 ..< min(4, count) {
            let view: UIView = {
                if i == 3, count > 3 {
                    let view = UIView()
                    if style == .current {
                        view.backgroundColor = .brandColor
                    } else {
                        view.backgroundColor = .systemGray6
                    }

                    view.translatesAutoresizingMaskIntoConstraints = false

                    let label = UILabel()
                    label.translatesAutoresizingMaskIntoConstraints = false

                    label.textColor = .label
                    if style == .current {
                        label.textColor = .white
                    }

                    label.font = .rounded(forTextStyle: .body, weight: .bold)
                    label.text = "+" + String(min(members.count - 3, 9))
                    view.addSubview(label)

                    NSLayoutConstraint.activate([
                        label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                        label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    ])

                    return view
                } else {
                    let view = UIImageView(image: nil)

                    let image = members[i].image
                    if image != "" {
                        view.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + image))
                    }

                    if style == .current {
                        view.backgroundColor = .systemGray6
                    } else {
                        view.backgroundColor = .brandColor
                    }

                    view.translatesAutoresizingMaskIntoConstraints = false
                    return view
                }
            }()

            contentView.addSubview(view)

            view.layer.borderWidth = 4.0
            view.layer.cornerRadius = 40 / 2
            view.layer.masksToBounds = true
            view.layer.borderColor = contentView.backgroundColor?.cgColor

            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20),
                view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
                view.heightAnchor.constraint(equalToConstant: 40.0),
                view.widthAnchor.constraint(equalToConstant: 40.0),
            ])

            if i == 0 {
                NSLayoutConstraint.activate([view.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20)])
            } else {
                NSLayoutConstraint.activate([view.leftAnchor.constraint(equalTo: previousView.rightAnchor, constant: -8)])
            }

            imageViews.append(view)
            previousView = view
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateBorders()
    }

    private func updateBorders() {
        for view in imageViews {
            view.layer.borderColor = contentView.backgroundColor?.cgColor
        }
    }
}
