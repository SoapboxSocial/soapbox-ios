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
        manager.drawer.openHeightBehavior = .fitting

        let activity = UIActivityIndicatorView(style: .large)
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.hidesWhenStopped = true
        view.addSubview(activity)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 10
        view.addSubview(stack)

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(groupLabel)

        groupLabel.isHidden = true

        titleLabel.text = "Dean's Room"

        let members = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        members.translatesAutoresizingMaskIntoConstraints = false
        members.backgroundColor = .clear
        view.addSubview(members)

        let muted = UILabel()
        muted.translatesAutoresizingMaskIntoConstraints = false
        muted.text = NSLocalizedString("you_will_be_muted_by_default", comment: "")
        muted.font = .rounded(forTextStyle: .subheadline, weight: .semibold)
        muted.textColor = .secondaryLabel
        muted.textAlignment = .center
        view.addSubview(muted)

        let button = Button(size: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("join_in", comment: ""), for: .normal)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: handle.topAnchor, constant: 10),
            stack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            stack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            members.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            members.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            members.heightAnchor.constraint(equalToConstant: 216),
            members.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            muted.topAnchor.constraint(equalTo: members.bottomAnchor, constant: 20),
            muted.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            muted.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: muted.bottomAnchor, constant: 20),
            button.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spacer)

        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: spacer.topAnchor),
        ])

        NSLayoutConstraint.activate([
            spacer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            activity.centerXAnchor.constraint(equalTo: members.centerXAnchor),
            activity.centerYAnchor.constraint(equalTo: members.centerYAnchor),
        ])

        activity.startAnimating()
    }
}
