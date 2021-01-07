import UIKit

class SettingsLinkTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .foreground

        accessoryView = UIImageView(image: UIImage(systemName: "arrow.up.right"))
        accessoryView?.tintColor = .secondaryLabel
        addSubview(accessoryView!)

        textLabel?.font = .rounded(forTextStyle: .body, weight: .regular)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
