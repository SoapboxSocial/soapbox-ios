import UIKit

class StoryReactionButton: UIButton {
    private let reaction: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .rounded(forTextStyle: .callout, weight: .semibold)
        return label
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .rounded(forTextStyle: .callout, weight: .semibold)
        label.text = "0"
        return label
    }()

    public var count: Int {
        didSet {
            countLabel.text = String(count)
        }
    }

    init(reaction: String) {
        self.reaction.text = reaction
        count = 0

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        addSubview(countLabel)
        addSubview(self.reaction)

        NSLayoutConstraint.activate([
            self.reaction.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            self.reaction.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
        ])

        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            countLabel.leftAnchor.constraint(equalTo: self.reaction.rightAnchor, constant: 10),
            countLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
        ])

        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 5),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
