import AlamofireImage
import NotificationBannerSwift
import UIKit

protocol InviteFriendsToGroupViewControllerOutput {
    func fetchFriends()
    func invite(friends: [Int])
}

class InviteFriendsToGroupViewController: UIViewController {
    var output: InviteFriendsToGroupViewControllerOutput!

    var list: UsersListWithSearch!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .brandColor

        let closeButton = UIButton()
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.titleLabel?.font = .rounded(forTextStyle: .body, weight: .medium)
        closeButton.setTitle(NSLocalizedString("close", comment: ""), for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(closeButton)

        let title = UILabel()
        title.font = .rounded(forTextStyle: .largeTitle, weight: .heavy)
        title.text = NSLocalizedString("invite_your_friends", comment: "")
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = .white
        view.addSubview(title)

        let inviteButton = Button(size: .large)
        inviteButton.setTitle(NSLocalizedString("invite", comment: ""), for: .normal)
        inviteButton.backgroundColor = .white
        inviteButton.setTitleColor(.black, for: .normal)
        inviteButton.translatesAutoresizingMaskIntoConstraints = false
        inviteButton.addTarget(self, action: #selector(invitePressed), for: .touchUpInside)
        view.addSubview(inviteButton)

        list = UsersListWithSearch(width: view.frame.size.width, allowsDeselection: false)
        view.addSubview(list)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            closeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            title.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            list.leftAnchor.constraint(equalTo: view.leftAnchor),
            list.rightAnchor.constraint(equalTo: view.rightAnchor),
            list.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20),
            list.bottomAnchor.constraint(equalTo: inviteButton.topAnchor),
        ])

        NSLayoutConstraint.activate([
            inviteButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            inviteButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            inviteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ])

        output.fetchFriends()
    }

    @objc private func close() {
        dismiss(animated: true)
    }

    @objc private func invitePressed() {
        output.invite(friends: list.selected)
    }
}

extension InviteFriendsToGroupViewController: InviteFriendsToGroupPresenterOutput {
    func present(users: [APIClient.User]) {
        list.set(users: users)
    }

    func presentInviteSucceeded() {
        dismiss(animated: true)
    }

    func presentError() {
        let banner = FloatingNotificationBanner(
            title: NSLocalizedString("something_went_wrong", comment: ""),
            subtitle: NSLocalizedString("please_try_again_later", comment: ""),
            style: .danger
        )
        banner.show(cornerRadius: 10, shadowBlurRadius: 15)
    }
}
