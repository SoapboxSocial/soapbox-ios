import UIKit

class RoomBadge: UIView {
    enum Style {
        case normal, current
    }

    var style: Style = .normal {
        didSet {
            switch style {
            case .normal:
                backgroundColor = .brandColor
                label.text = NSLocalizedString("join_in", comment: "")
                label.textColor = .white
            case .current:
                backgroundColor = .white
                label.text = NSLocalizedString("join_in", comment: "")
                label.textColor = .black
            }
        }
    }

    private var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("join_in", comment: "")
        label.font = .rounded(forTextStyle: .title3, weight: .bold)
        label.textColor = .white
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .brandColor
        layer.cornerRadius = 15

        addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
