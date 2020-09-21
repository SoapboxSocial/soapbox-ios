import UIKit

class ProfileViewControllerV2: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let image = UIImageView()
        image.backgroundColor = .brandColor
        image.layer.cornerRadius = 80 / 2
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(image)

        let displayName = UILabel()
        displayName.translatesAutoresizingMaskIntoConstraints = false
        displayName.font = .rounded(forTextStyle: .title2, weight: .bold)
        view.addSubview(displayName)

        let username = UILabel()
        username.translatesAutoresizingMaskIntoConstraints = false
        username.font = .rounded(forTextStyle: .title3, weight: .regular)
        view.addSubview(username)

        let followersView = UIView()
        followersView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(followersView)

        let followersCountLabel = UILabel()
        followersCountLabel.translatesAutoresizingMaskIntoConstraints = false
        followersCountLabel.font = .rounded(forTextStyle: .body, weight: .semibold)
        followersView.addSubview(followersCountLabel)

        let followersLabel = UILabel()
        followersLabel.translatesAutoresizingMaskIntoConstraints = false
        followersLabel.font = .rounded(forTextStyle: .body, weight: .regular)
        followersView.addSubview(followersLabel)

        let followingView = UIView()
        followingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(followingView)

        let followingCountLabel = UILabel()
        followingCountLabel.translatesAutoresizingMaskIntoConstraints = false
        followingCountLabel.font = .rounded(forTextStyle: .body, weight: .semibold)
        followingView.addSubview(followingCountLabel)

        let followingLabel = UILabel()
        followingLabel.translatesAutoresizingMaskIntoConstraints = false
        followingLabel.font = .rounded(forTextStyle: .body, weight: .regular)
        followingLabel.text = NSLocalizedString("following", comment: "")
        followingView.addSubview(followingLabel)

        followersLabel.text = NSLocalizedString("followers", comment: "")

        displayName.text = "Dean Eigenmann"
        username.text = "@dean"
        followersCountLabel.text = "35.3K"
        followingCountLabel.text = "1"

        NSLayoutConstraint.activate([
            image.heightAnchor.constraint(equalToConstant: 80),
            image.widthAnchor.constraint(equalToConstant: 80),
            image.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            image.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            displayName.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20),
            displayName.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            displayName.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            username.topAnchor.constraint(equalTo: displayName.bottomAnchor, constant: 5),
            username.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            followersView.topAnchor.constraint(equalTo: username.bottomAnchor, constant: 20),
            followersView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            followersView.bottomAnchor.constraint(equalTo: followersLabel.bottomAnchor),
            followersView.rightAnchor.constraint(equalTo: followersLabel.rightAnchor),
        ])

        NSLayoutConstraint.activate([
            followersCountLabel.topAnchor.constraint(equalTo: followersView.topAnchor, constant: 20),
            followersCountLabel.leftAnchor.constraint(equalTo: followersView.leftAnchor, constant: 0),
        ])

        NSLayoutConstraint.activate([
            followersLabel.topAnchor.constraint(equalTo: followersCountLabel.bottomAnchor, constant: 0),
            followersLabel.leftAnchor.constraint(equalTo: followersCountLabel.leftAnchor, constant: 0),
        ])

        NSLayoutConstraint.activate([
            followingView.topAnchor.constraint(equalTo: username.bottomAnchor, constant: 20),
            followingView.leftAnchor.constraint(equalTo: followersView.rightAnchor, constant: 40),
            followingView.bottomAnchor.constraint(equalTo: followersLabel.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            followingCountLabel.topAnchor.constraint(equalTo: followingView.topAnchor, constant: 20),
            followingCountLabel.leftAnchor.constraint(equalTo: followingView.leftAnchor, constant: 0),
        ])

        NSLayoutConstraint.activate([
            followingLabel.topAnchor.constraint(equalTo: followingCountLabel.bottomAnchor, constant: 0),
            followingLabel.leftAnchor.constraint(equalTo: followingCountLabel.leftAnchor, constant: 0),
        ])
    }
}
