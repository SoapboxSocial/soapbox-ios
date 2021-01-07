import UIKit

class SettingsLinkTableViewCell: UITableViewCell {
    init() {
        super.init(style: .default, reuseIdentifier: "poop")

        backgroundColor = .foreground

        accessoryView = UIImageView(image: UIImage(systemName: "arrow.up.right"))
        accessoryView?.tintColor = .label
        addSubview(accessoryView!)

        textLabel?.text = "test"
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
