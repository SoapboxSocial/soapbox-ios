import UIKit

class RoomPreviewOverflowCell: UICollectionViewCell {
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.rounded(forTextStyle: .body, weight: .black).withSize(32)
        return label
    }()

    private let circle: UIView = {
        let view = UIView()
        view.backgroundColor = .brandColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(circle)

        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        circle.addSubview(view)

        let plus = UILabel()
        plus.translatesAutoresizingMaskIntoConstraints = false
        plus.textColor = .white

        plus.font = .rounded(forTextStyle: .body, weight: .black)
        plus.text = "+"
        view.addSubview(plus)

        view.addSubview(label)

        NSLayoutConstraint.activate([
            circle.widthAnchor.constraint(equalTo: widthAnchor),
            circle.heightAnchor.constraint(equalTo: widthAnchor),
            circle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        NSLayoutConstraint.activate([
            plus.leftAnchor.constraint(equalTo: leftAnchor),
            plus.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: plus.rightAnchor),
            label.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: plus.leftAnchor),
            view.rightAnchor.constraint(equalTo: label.rightAnchor),
            view.topAnchor.constraint(equalTo: label.topAnchor),
            view.bottomAnchor.constraint(equalTo: label.bottomAnchor),
            view.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            view.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        circle.layer.cornerRadius = circle.frame.size.width / 2
    }
}
