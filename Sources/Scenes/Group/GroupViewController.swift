import FocusableImageView
import NotificationBannerSwift
import UIKit

protocol GroupViewControllerOutput {
    func loadData()
    func acceptInvite()
    func declineInvite()
    func join()
}

class GroupViewController: ViewController {
    var output: GroupViewControllerOutput!

    private let content: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 20
        view.distribution = .fill
        view.alignment = .fill
        view.axis = .vertical
        return view
    }()

    private var inviteView: GroupInviteView = {
        let view = GroupInviteView()
        return view
    }()

    private var headerView: ProfileHeaderView = {
        ProfileHeaderView()
    }()

    private var membersCountView: StatisticView = {
        StatisticView()
    }()

    private var inviteButton: Button = {
        let button = Button(size: .small)
        button.setImage(
            UIImage(systemName: "person.badge.plus", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
            for: .normal
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        return button
    }()

    private var id: Int!

    private lazy var manager = FocusableImageViewManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        scrollView.addSubview(content)

        content.addArrangedSubview(headerView)
        content.addArrangedSubview(inviteView)
        content.addArrangedSubview(membersCountView)

        membersCountView.descriptionLabel.text = NSLocalizedString("members", comment: "")
        membersCountView.handleTap(target: self, action: #selector(didTapMembers))

        inviteView.isHidden = true

        inviteView.acceptButton.addTarget(self, action: #selector(acceptInvite), for: .touchUpInside)
        inviteView.declineButton.addTarget(self, action: #selector(declineInvite), for: .touchUpInside)

        headerView.addSubview(inviteButton)

        inviteButton.addTarget(self, action: #selector(didTapInviteButton), for: .touchUpInside)
        inviteButton.isHidden = true

        headerView.button.setTitle(NSLocalizedString("join", comment: ""), for: .normal)
        headerView.button.setTitle(NSLocalizedString("joined", comment: ""), for: .selected)

        NSLayoutConstraint.activate([
            inviteButton.bottomAnchor.constraint(equalTo: headerView.image.bottomAnchor),
            inviteButton.rightAnchor.constraint(equalTo: headerView.button.leftAnchor, constant: -10),
        ])

        NSLayoutConstraint.activate([
            headerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            headerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            inviteView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            inviteView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            membersCountView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: view.topAnchor),
            content.leftAnchor.constraint(equalTo: view.leftAnchor),
            content.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])

        output.loadData()
    }

    @objc private func acceptInvite() {
        output.acceptInvite()
    }

    @objc private func declineInvite() {
        output.declineInvite()
    }
}

extension GroupViewController: GroupPresenterOutput {
    func display(group: APIClient.Group) {
        title = group.name
        headerView.titleLabel.text = group.name
        headerView.descriptionLabel.text = group.description
        id = group.id

        if group.groupType == .public {
            headerView.button.isHidden = false
            headerView.button.addTarget(self, action: #selector(didTapJoin), for: .touchUpInside)
        }

        membersCountView.statistic.text = String(group.members ?? 0)

        if let role = group.role {
            showJoinedBadge()

            if role == .admin {
                inviteButton.isHidden = false
            }
        }

        if let image = group.image, image != "" {
            headerView.image.inner.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/groups/" + image))
            headerView.image.inner.contentMode = .scaleAspectFill
            manager.register(parentViewController: self, imageViews: [headerView.image])
        }
    }

    func display(invite: APIClient.User) {
        let fmt = NSLocalizedString("user_invited_you_to_join_group", comment: "")
        let data = String(format: fmt, invite.displayName, title!)
        inviteView.label.text = data

        if let image = invite.image, image != "" {
            inviteView.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + image))
            inviteView.image.contentMode = .scaleAspectFill
        }

        inviteView.isHidden = false
    }

    func displayInviteAccepted() {
        showJoinedBadge()
        removeInviteView()
    }

    func displayInviteDeclined() {
        removeInviteView()
    }

    func displayJoined() {
        showJoinedBadge()
        removeInviteView()
    }

    func displayError() {
        let banner = FloatingNotificationBanner(
            title: NSLocalizedString("something_went_wrong", comment: ""),
            subtitle: NSLocalizedString("please_try_again_later", comment: ""),
            style: .danger
        )
        banner.show(cornerRadius: 10, shadowBlurRadius: 15)
    }

    private func showJoinedBadge() {
        headerView.button.isSelected = true
        headerView.button.isHidden = false
    }

    private func removeInviteView() {
        UIView.animate(
            withDuration: 0.2,
            animations: { self.inviteView.isHidden = true },
            completion: { _ in self.content.removeArrangedSubview(self.inviteView) }
        )
    }

    @objc private func didTapMembers() {
        let list = SceneFactory.createUserViewController(id: id, title: NSLocalizedString("members", comment: ""), userListFunc: APIClient().groupMembers)
        navigationController?.pushViewController(list, animated: true)
    }

    @objc private func didTapInviteButton() {
        let view = SceneFactory.createInviteFriendsToGroupViewController(id: id)
        present(view, animated: true)
    }

    @objc private func didTapJoin() {
        if headerView.button.isSelected {
            return
        }

        output.join()
    }
}
