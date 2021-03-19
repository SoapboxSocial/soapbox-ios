import UIKit

class RoomPreviewViewController: DrawerViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .rounded(forTextStyle: .title2, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let groupLabel: UILabel = {
        let label = UILabel()
        label.font = .rounded(forTextStyle: .subheadline, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        manager.drawer.backgroundColor = .foreground

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 10
        view.addSubview(stack)

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(groupLabel)

        groupLabel.isHidden = true

        NSLayoutConstraint.activate([
            stack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            stack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])
    }
}
