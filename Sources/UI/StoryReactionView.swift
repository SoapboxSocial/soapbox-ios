import UIKit

class StoryReactionView: UIView {
    private let reaction: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .rounded(forTextStyle: .callout, weight: .semibold)
        return label
    }()

    private let count: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .rounded(forTextStyle: .callout, weight: .semibold)
        return label
    }()

    init(reaction: String, count: Int) {
        self.reaction.text = reaction
        self.count.text = String(count)

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        addSubview(self.reaction)
        addSubview(self.count)

        NSLayoutConstraint.activate([
            self.reaction.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            self.reaction.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
        ])

        NSLayoutConstraint.activate([
            self.count.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            self.count.leftAnchor.constraint(equalTo: self.reaction.rightAnchor, constant: 10),
            self.count.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
        ])

        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: self.count.bottomAnchor, constant: 5),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
