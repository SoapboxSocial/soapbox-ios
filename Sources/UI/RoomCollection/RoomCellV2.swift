import UIKit

class RoomCellV2: UICollectionViewCell {
    enum RoomStyle {
        case normal, current
    }

    var style: RoomStyle = .normal {
        didSet {
            switch style {
            case .normal:
                roomView.backgroundColor = .systemGray6
                badge.style = .normal
                title.textColor = .black
                updateImageColors(border: UIColor.systemGray6.cgColor, background: UIColor.brandColor)
            case .current:
                badge.style = .current
                roomView.backgroundColor = .brandColor
                title.textColor = .white
                updateImageColors(border: UIColor.brandColor.cgColor, background: UIColor.systemGray6)
            }
        }
    }

    var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title2, weight: .bold)
        label.textColor = .label
        return label
    }()

    var images: Int = 3 {
        didSet {
            imageViews.forEach { $0.removeFromSuperview() }
            createImageView(images)
        }
    }

    private var roomView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 30
        return view
    }()

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

        addSubview(roomView)

        roomView.addSubview(title)
        roomView.addSubview(badge)

        NSLayoutConstraint.activate([
            roomView.topAnchor.constraint(equalTo: topAnchor, constant: 10), // @TODO THIS SEEMS TO BE TOO BIG?
            roomView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            roomView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            roomView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: roomView.topAnchor, constant: 20),
            title.leftAnchor.constraint(equalTo: roomView.leftAnchor, constant: 20),
            title.rightAnchor.constraint(equalTo: roomView.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            badge.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20),
            badge.rightAnchor.constraint(equalTo: roomView.rightAnchor, constant: -20),
            badge.bottomAnchor.constraint(equalTo: roomView.bottomAnchor, constant: -20),
        ])

        createImageView(4)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        for view in imageViews {
            view.layer.cornerRadius = view.frame.size.height / 2
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createImageView(_ count: Int) {
        var previousView = roomView

        for i in 0 ..< count {
            let view = UIImageView(image: nil)
            view.backgroundColor = .brandColor
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.borderWidth = 4.0
            view.layer.borderColor = roomView.backgroundColor?.cgColor
            roomView.addSubview(view)

            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20),
                view.bottomAnchor.constraint(equalTo: roomView.bottomAnchor, constant: -20),
                view.heightAnchor.constraint(equalTo: badge.heightAnchor),
                view.widthAnchor.constraint(equalTo: badge.heightAnchor),
            ])

            if i == 0 {
                NSLayoutConstraint.activate([view.leftAnchor.constraint(equalTo: roomView.leftAnchor, constant: 20)])
            } else {
                NSLayoutConstraint.activate([view.leftAnchor.constraint(equalTo: previousView.rightAnchor, constant: -8)])
            }

            imageViews.append(view)
            previousView = view
        }
    }

    private func updateImageColors(border: CGColor, background: UIColor) {
        for (i, view) in imageViews.enumerated() {
            view.layer.borderColor = border

            if i == imageViews.count - 1 {
                view.backgroundColor = roomView.backgroundColor
            } else {
                view.backgroundColor = background
            }
        }
    }
}
