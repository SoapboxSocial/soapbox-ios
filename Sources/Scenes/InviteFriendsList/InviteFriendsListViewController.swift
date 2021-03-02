import AlamofireImage
import UIKit

protocol InviteFriendsListViewControllerOutput {
    func fetchFriends()
    func didSelect(user: Int)
}

class InviteFriendsListViewController: UIViewController {
    var output: InviteFriendsListViewControllerOutput!

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

        list = UsersListWithSearch(width: view.frame.size.width, allowsDeselection: false)
        list.delegate = self
        view.addSubview(list)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            closeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 20),
            title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            title.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            list.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20),
            list.leftAnchor.constraint(equalTo: view.leftAnchor),
            list.rightAnchor.constraint(equalTo: view.rightAnchor),
            list.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        output.fetchFriends()
    }

    @objc private func close() {
        dismiss(animated: true)
    }
}

extension InviteFriendsListViewController: InviteFriendsListPresenterOutput {
    func present(success: String) {
        let fmt = NSLocalizedString("user_invited", comment: "")
        let banner = NotificationBanner(title: String(format: fmt, success), style: .success, type: .floating)
        banner.show()
    }

    func present(users: [APIClient.User]) {
        list.set(users: users)
    }
}

extension InviteFriendsListViewController: UsersListWithSearchDelegate {
    func usersList(_: UsersListWithSearch, didSelect id: Int) {
        output.didSelect(user: id)
    }
}
