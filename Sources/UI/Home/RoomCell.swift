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
                lockImage.tintColor = .label
                groupLabel.textColor = .secondaryLabel
            case .current:
                badge.style = .current
                contentView.backgroundColor = .brandColor
                lockImage.tintColor = .white
                title.textColor = .white
                groupLabel.textColor = .white
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
            } else {
                lock.isHidden = true
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

    private var lockImage: UIImageView = {
        let lock = UIImageView(image: UIImage(systemName: "lock", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)))
        lock.tintColor = .label
        lock.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        lock.translatesAutoresizingMaskIntoConstraints = false
        return lock
    }()

    private var lock: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var group: RoomState.Group? {
        didSet {
            if group == nil {
                groupView.isHidden = true
            } else {
                if let image = group?.image, image != "" {
                    groupImage.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/groups/" + image))
                }

                groupLabel.text = group?.name
                groupView.isHidden = false
            }
        }
    }

    private var groupLabel: UILabel = {
        let label = UILabel()
        label.font = .rounded(forTextStyle: .footnote, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var groupImage: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 24 / 2
        image.layer.masksToBounds = true
        image.backgroundColor = .background
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    private var groupView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var imageViews = [UIView]()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width).isActive = true

        let topScroll = UIStackView()
        topScroll.translatesAutoresizingMaskIntoConstraints = false
        topScroll.spacing = 10
        topScroll.distribution = .fill
        topScroll.alignment = .fill
        topScroll.axis = .vertical
        contentView.addSubview(topScroll)

        let titleScroll = UIStackView()
        titleScroll.translatesAutoresizingMaskIntoConstraints = false
        titleScroll.spacing = 10
        titleScroll.distribution = .fill
        titleScroll.alignment = .fill
        titleScroll.axis = .horizontal

        contentView.backgroundColor = .foreground
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.cornerRadius = 30

        groupView.addSubview(groupImage)
        groupView.addSubview(groupLabel)

        groupLabel.text = "this is a test"

        topScroll.addArrangedSubview(groupView)
        topScroll.addArrangedSubview(titleScroll)

        titleScroll.addArrangedSubview(lock)
        titleScroll.addArrangedSubview(title)

        lock.addSubview(lockImage)

        contentView.addSubview(badge)

        NSLayoutConstraint.activate([
            groupImage.leftAnchor.constraint(equalTo: groupView.leftAnchor),
            groupImage.widthAnchor.constraint(equalToConstant: 24),
            groupImage.heightAnchor.constraint(equalToConstant: 24),
        ])

        NSLayoutConstraint.activate([
            groupLabel.centerYAnchor.constraint(equalTo: groupImage.centerYAnchor),
            groupLabel.leftAnchor.constraint(equalTo: groupImage.rightAnchor, constant: 8),
            groupLabel.rightAnchor.constraint(equalTo: groupView.rightAnchor),
        ])

        NSLayoutConstraint.activate([
            lockImage.heightAnchor.constraint(equalToConstant: 20),
            lockImage.widthAnchor.constraint(equalToConstant: 20),
        ])

        NSLayoutConstraint.activate([
            lock.heightAnchor.constraint(equalToConstant: 20),
            lock.widthAnchor.constraint(equalToConstant: 20),
            lock.leftAnchor.constraint(equalTo: titleScroll.leftAnchor),
        ])

        NSLayoutConstraint.activate([
            title.centerYAnchor.constraint(equalTo: titleScroll.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        NSLayoutConstraint.activate([
            groupView.leftAnchor.constraint(equalTo: topScroll.leftAnchor),
            groupView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            groupView.heightAnchor.constraint(equalToConstant: 24),
        ])

        groupView.isHidden = true

        NSLayoutConstraint.activate([
            topScroll.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            topScroll.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            topScroll.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            topScroll.bottomAnchor.constraint(equalTo: titleScroll.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            titleScroll.leftAnchor.constraint(equalTo: topScroll.leftAnchor),
            titleScroll.rightAnchor.constraint(equalTo: topScroll.rightAnchor),
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
