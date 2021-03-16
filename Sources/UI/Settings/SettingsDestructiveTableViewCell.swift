import UIKit

class SettingsDestructiveTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)

        textLabel?.font = .rounded(forTextStyle: .body, weight: .regular)
        textLabel?.textColor = .systemRed
        textLabel?.textAlignment = .center
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
