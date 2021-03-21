import UIKit

protocol RoomPreviewViewControllerDelegate: AnyObject {
    func roomPreviewViewController(_ view: RoomPreviewViewController, shouldJoin room: String)
}

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

    private let id: String

    weak var delegate: RoomPreviewViewControllerDelegate?

    private var room: RoomAPIClient.Room?

    init(id: String) {
        self.id = id
        super.init()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

        titleLabel.text = NSLocalizedString("listen_in", comment: "")

        let members = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout.basicUserBubbleLayout(itemsPerRow: 4, width: view.frame.size.width - 40)
        )

        members.translatesAutoresizingMaskIntoConstraints = false
        members.backgroundColor = .clear
        members.register(cellWithClass: SelectableImageTextCell.self)
        members.dataSource = self
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
        button.addTarget(self, action: #selector(didTapJoin), for: .touchUpInside)
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

        RoomAPIClient().room(id: id, callback: { result in
            switch result {
            case .failure:
                // @TODO close cause room not found
                break
            case let .success(room):
                if room.name != "" {
                    self.titleLabel.text = room.name
                }

                if let group = room.group {
                    self.groupLabel.text = group.name
                }

                self.room = room

                DispatchQueue.main.async {
                    activity.stopAnimating()
                    members.reloadData()
                }
            }
        })
    }

    @objc private func didTapJoin() {
        delegate?.roomPreviewViewController(self, shouldJoin: id)
    }
}

extension RoomPreviewViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: SelectableImageTextCell.self, for: indexPath)

        let user = room!.members[indexPath.item]
        if user.image != "" {
            cell.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + user.image))
        }

        cell.selectedView.isHidden = true
        cell.title.text = user.displayName.firstName()

        return cell
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        guard let members = room?.members else {
            return 0
        }

        return min(members.count, 8)
    }
}
