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
                lock.tintColor = .label
            case .current:
                badge.style = .current
                contentView.backgroundColor = .brandColor
                lock.tintColor = .white
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

    var visibility = Visibility.private {
        didSet {
            if visibility == .private {
                lock.isHidden = false
                titleLeftAnchorConstraint.constant = 5
            } else {
                lock.isHidden = true
                titleLeftAnchorConstraint.constant = -20
            }

            DispatchQueue.main.async {
                self.layoutIfNeeded()
            }
        }
    }

    var members = [RoomState.RoomMember]() {
        didSet {
            createImageViews()

            if members.count >= 16 {
                badge.label.text = NSLocalizedString("full", comment: "")
            }
        }
    }

    private var badge: RoomBadge = {
        let badge = RoomBadge(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        badge.translatesAutoresizingMaskIntoConstraints = false
        return badge
    }()

    private var lock: UIImageView = {
        let lock = UIImageView(image: UIImage(systemName: "lock", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)))
        lock.tintColor = .label
        lock.translatesAutoresizingMaskIntoConstraints = false
        return lock
    }()

    var group: RoomState.Group? {
        didSet {
            groupLabel.text = group?.name
            groupView.isHidden = false
        }
    }

    private var groupLabel: UILabel {
        let label = UILabel()
        label.font = .rounded(forTextStyle: .footnote, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private var groupImage: UIImageView {
        let image = UIImageView()
        image.layer.cornerRadius = 24 / 2
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }

    private var groupView: UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private var titleLeftAnchorConstraint: NSLayoutConstraint!

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

        contentView.addSubview(lock)

        titleLeftAnchorConstraint = title.leftAnchor.constraint(equalTo: lock.rightAnchor, constant: 5)

        // @TODO MAYBE USE STACK VIEW?
        NSLayoutConstraint.activate([
            lock.heightAnchor.constraint(equalToConstant: 20),
            lock.widthAnchor.constraint(equalToConstant: 20),
            lock.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            lock.centerYAnchor.constraint(equalTo: title.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLeftAnchorConstraint,
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
                        view.backgroundColor = .foreground
                    }

                    view.translatesAutoresizingMaskIntoConstraints = false

                    let label = UILabel()
                    label.translatesAutoresizingMaskIntoConstraints = false

                    label.textColor = .label
                    if style == .current {
                        label.textColor = .white
                    }

                    label.font = .rounded(forTextStyle: .body, weight: .black)
                    label.text = String(min(members.count - 3, 9))
                    view.addSubview(label)

                    let plus = UILabel()
                    plus.translatesAutoresizingMaskIntoConstraints = false

                    plus.textColor = .label
                    if style == .current {
                        plus.textColor = .white
                    }

                    plus.font = .rounded(forTextStyle: .caption2, weight: .black)
                    plus.text = "+"
                    view.addSubview(plus)

                    NSLayoutConstraint.activate([
                        plus.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 7),
                        plus.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    ])

                    NSLayoutConstraint.activate([
                        label.leftAnchor.constraint(equalTo: plus.rightAnchor),
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
