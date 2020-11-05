import FocusableImageView
import UIKit

protocol GroupViewControllerOutput {
    func loadData()
}

class GroupViewController: UIViewController {
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

    private var headerView: GroupHeaderView = {
        GroupHeaderView()
    }()

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

        inviteView.isHidden = true

        inviteView.acceptButton.addTarget(self, action: #selector(acceptInvite), for: .touchUpInside)
        inviteView.declineButton.addTarget(self, action: #selector(declineInvite), for: .touchUpInside)

        NSLayoutConstraint.activate([
            headerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            headerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            inviteView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            inviteView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
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
        removeInviteView()
    }

    @objc private func declineInvite() {
        removeInviteView()
    }

    private func removeInviteView() {
        UIView.animate(
            withDuration: 0.2,
            animations: { self.inviteView.isHidden = true },
            completion: { _ in self.content.removeArrangedSubview(self.inviteView) }
        )
    }
}

extension GroupViewController: GroupPresenterOutput {
    func display(group: APIClient.Group) {
        title = group.name
        headerView.titleLabel.text = group.name
        headerView.descriptionLabel.text = group.description

        if group.isMember ?? false {
            headerView.button.isSelected = true
            headerView.button.isHidden = false
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
}
