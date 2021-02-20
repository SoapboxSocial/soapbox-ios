import UIKit

class SettingsSelectionTableViewCell: UITableViewCell {
    let selection: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .body, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .foreground

        addSubview(selection)

        NSLayoutConstraint.activate([
            selection.rightAnchor.constraint(equalTo: rightAnchor, constant: -15),
            selection.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        textLabel?.font = .rounded(forTextStyle: .body, weight: .regular)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
