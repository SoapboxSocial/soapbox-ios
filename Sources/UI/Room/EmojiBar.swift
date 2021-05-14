import UIKit

protocol EmojiBarDelegate {
    func did(react reaction: Room.Reaction)
}

class EmojiBar: UIView {
    var delegate: EmojiBarDelegate?

    init(emojis: [Room.Reaction]) {
        super.init(frame: CGRect.zero)

        translatesAutoresizingMaskIntoConstraints = false

        var left = leftAnchor
        var leftOffset = CGFloat(0)

        for emoji in emojis {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(emoji.rawValue, for: .normal)
            button.addTarget(self, action: #selector(reactionTapped), for: .touchUpInside)
            button.backgroundColor = .clear
            addSubview(button)

            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 32),
                button.widthAnchor.constraint(equalToConstant: 32),
                button.leftAnchor.constraint(equalTo: left, constant: leftOffset),
            ])

            left = button.rightAnchor
            leftOffset = 20
        }

        NSLayoutConstraint.activate([
            rightAnchor.constraint(equalTo: left),
            heightAnchor.constraint(equalToConstant: 32),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func reactionTapped(_ sender: UIButton) {
        guard let label = sender.title(for: .normal) else {
            return
        }

        guard let reaction = Room.Reaction(rawValue: label) else {
            return
        }

        delegate?.did(react: reaction)
    }
}
