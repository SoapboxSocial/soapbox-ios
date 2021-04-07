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
                title.textColor = .label
                lockImage.tintColor = .label
            case .current:
                contentView.backgroundColor = .brandColor
                lockImage.tintColor = .white
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

    var visibility = RoomAPIClient.Room.Visibility.public {
        didSet {
            if visibility == .private {
                lock.isHidden = false
            } else {
                lock.isHidden = true
            }
        }
    }

    var members = [RoomAPIClient.Member]() {
        didSet {
            createImageViews()
        }
    }

    private var lockImage: UIView = {
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

    private var topStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 10
        stack.distribution = .fill
        stack.alignment = .fill
        stack.axis = .vertical
        return stack
    }()

    private var imageViews = [UIView]()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width).isActive = true

        contentView.addSubview(topStack)

        let titleStack = UIStackView()
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.spacing = 10
        titleStack.distribution = .fill
        titleStack.alignment = .center
        titleStack.axis = .horizontal

        contentView.backgroundColor = .foreground
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.cornerRadius = 30

        topStack.addArrangedSubview(titleStack)

        titleStack.addArrangedSubview(lock)
        titleStack.addArrangedSubview(title)

        lock.addSubview(lockImage)

        NSLayoutConstraint.activate([
            lockImage.heightAnchor.constraint(equalToConstant: 20),
            lockImage.widthAnchor.constraint(equalToConstant: 20),
        ])

        NSLayoutConstraint.activate([
            lock.heightAnchor.constraint(equalToConstant: 20),
            lock.widthAnchor.constraint(equalToConstant: 20),
            lock.leftAnchor.constraint(equalTo: titleStack.leftAnchor),
            lock.centerYAnchor.constraint(equalTo: titleStack.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            titleStack.heightAnchor.constraint(equalToConstant: 28),
            titleStack.bottomAnchor.constraint(equalTo: title.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            topStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            topStack.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            topStack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            titleStack.leftAnchor.constraint(equalTo: topStack.leftAnchor),
            titleStack.rightAnchor.constraint(equalTo: topStack.rightAnchor),
        ])

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
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
        let visible = 6

        for i in 0 ..< min(visible + 1, count) {
            let view: UIView = {
                if i == visible, count > visible {
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
                    label.text = String(min(members.count - visible, 9))
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
                view.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 30),
                view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
                view.heightAnchor.constraint(equalToConstant: 40.0),
                view.widthAnchor.constraint(equalToConstant: 40.0),
            ])

            if i == 0 {
                view.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
            } else {
                view.leftAnchor.constraint(equalTo: previousView.rightAnchor, constant: -8).isActive = true
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

    override func prepareForReuse() {
        super.prepareForReuse()

        imageViews.forEach { $0.removeFromSuperview() }
        title.text = ""
    }
}
