import UIKit

class SettingsToggleTableViewCell: UITableViewCell {
    let toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()

    var handler: ((Bool) -> Void)!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .foreground

        addSubview(toggle)
        accessoryView = toggle

        NSLayoutConstraint.activate([
            toggle.rightAnchor.constraint(equalTo: rightAnchor, constant: -15),
            toggle.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        textLabel?.font = .rounded(forTextStyle: .body, weight: .regular)
        toggle.addTarget(self, action: #selector(toggled), for: .valueChanged)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        handler = nil
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func toggled() {
        handler(toggle.isOn)
    }
}
