import UIKit

class StatisticView: UIView {
    var statistic: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .body, weight: .semibold)
        return label
    }()

    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .body, weight: .regular)
        return label
    }()

    init() {
        super.init(frame: CGRect.zero)

        translatesAutoresizingMaskIntoConstraints = false

        addSubview(statistic)
        addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            statistic.topAnchor.constraint(equalTo: topAnchor),
            statistic.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
        ])

        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: statistic.bottomAnchor),
            descriptionLabel.leftAnchor.constraint(equalTo: statistic.leftAnchor),
        ])

        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor),
            rightAnchor.constraint(equalTo: descriptionLabel.rightAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
