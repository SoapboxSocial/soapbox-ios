import UIKit

class CreateRoomButton: ButtonWithSpringAnimation {
    private let feedback: UIImpactFeedbackGenerator = {
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.prepare()
        return feedback
    }()

    override init() {
        super.init()

        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .brandColor

        setImage(UIImage(systemName: "quote.bubble.fill"), for: .normal)

        setTitle(NSLocalizedString("create_room", comment: ""), for: .normal)
        setTitleColor(.white, for: .normal)

        titleLabel?.font = .rounded(forTextStyle: .title2, weight: .bold)
        titleLabel?.translatesAutoresizingMaskIntoConstraints = false

        tintColor = .white
        adjustsImageWhenHighlighted = false

        imageView?.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView!.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            imageView!.widthAnchor.constraint(equalToConstant: 32),
            imageView!.heightAnchor.constraint(equalToConstant: 32),
            imageView!.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView!.rightAnchor.constraint(equalTo: titleLabel!.leftAnchor, constant: -10),
        ])

        NSLayoutConstraint.activate([
            titleLabel!.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel!.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),
            titleLabel!.rightAnchor.constraint(equalTo: rightAnchor, constant: -18),
        ])

        addTarget(self, action: #selector(didPress), for: [.touchUpInside])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.height / 2
    }

    @objc private func didPress() {
        feedback.impactOccurred()
        feedback.prepare()
    }
}
