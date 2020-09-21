import AlamofireImage
import UIKit

protocol ProfileViewControllerOutput {
    func loadData()
}

class ProfileViewControllerV2: UIViewController {
    var id: Int!

    var output: ProfileViewControllerOutput!

    private let image: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .brandColor
        image.layer.cornerRadius = 80 / 2
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    private let displayName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title2, weight: .bold)
        return label
    }()

    private let username: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title3, weight: .regular)
        return label
    }()

    private let followersCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .body, weight: .semibold)
        return label
    }()

    private let followingCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .body, weight: .semibold)
        return label
    }()

    private let followsYouBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()

    private let followButton: SoapButton = {
        let button = SoapButton(size: .regular)
        button.setTitle(NSLocalizedString("follow", comment: ""), for: .normal)
        button.setTitle(NSLocalizedString("unfollow", comment: ""), for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        output.loadData()

        view.addSubview(image)
        view.addSubview(displayName)
        view.addSubview(username)
        view.addSubview(followButton)
        view.addSubview(followsYouBadge)

        let followsYouLabel = UILabel()
        followsYouLabel.translatesAutoresizingMaskIntoConstraints = false
        followsYouLabel.font = .rounded(forTextStyle: .body, weight: .semibold)
        followsYouLabel.textColor = .systemGray2
        followsYouLabel.text = NSLocalizedString("follows_you", comment: "")
        followsYouBadge.addSubview(followsYouLabel)

        let followersRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapFollowersLabel))

        let followersView = UIView()
        followersView.translatesAutoresizingMaskIntoConstraints = false
        followersView.addGestureRecognizer(followersRecognizer)
        followersView.isUserInteractionEnabled = true
        view.addSubview(followersView)

        followersView.addSubview(followersCountLabel)

        let followersLabel = UILabel()
        followersLabel.translatesAutoresizingMaskIntoConstraints = false
        followersLabel.font = .rounded(forTextStyle: .body, weight: .regular)
        followersView.addSubview(followersLabel)

        let followingRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapFollowingLabel))

        let followingView = UIView()
        followingView.translatesAutoresizingMaskIntoConstraints = false
        followingView.addGestureRecognizer(followingRecognizer)
        followingView.isUserInteractionEnabled = true
        view.addSubview(followingView)

        followingView.addSubview(followingCountLabel)

        let followingLabel = UILabel()
        followingLabel.translatesAutoresizingMaskIntoConstraints = false
        followingLabel.font = .rounded(forTextStyle: .body, weight: .regular)
        followingLabel.text = NSLocalizedString("following", comment: "")
        followingView.addSubview(followingLabel)

        followersLabel.text = NSLocalizedString("followers", comment: "")

        NSLayoutConstraint.activate([
            image.heightAnchor.constraint(equalToConstant: 80),
            image.widthAnchor.constraint(equalToConstant: 80),
            image.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            image.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            followButton.centerYAnchor.constraint(equalTo: image.centerYAnchor),
            followButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
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
            followsYouBadge.centerYAnchor.constraint(equalTo: username.centerYAnchor),
            followsYouBadge.leftAnchor.constraint(equalTo: username.rightAnchor, constant: 10),
        ])

        NSLayoutConstraint.activate([
            followsYouLabel.topAnchor.constraint(equalTo: followsYouBadge.topAnchor),
            followsYouLabel.leftAnchor.constraint(equalTo: followsYouBadge.leftAnchor, constant: 8),
            followsYouLabel.rightAnchor.constraint(equalTo: followsYouBadge.rightAnchor, constant: -8),
            followsYouLabel.bottomAnchor.constraint(equalTo: followsYouBadge.bottomAnchor),
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
            followingView.rightAnchor.constraint(equalTo: followingLabel.rightAnchor),
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

    // @TODO THIS SHOULD BE DONE THROUGH INTERACTOR FLOW
    @objc private func didTapFollowersLabel() {
        let list = SceneFactory.createFollowerViewController(id: id, userListFunc: APIClient().followers)
        navigationController?.pushViewController(list, animated: true)
    }

    @objc private func didTapFollowingLabel() {
        let list = SceneFactory.createFollowerViewController(id: id, userListFunc: APIClient().following)
        navigationController?.pushViewController(list, animated: true)
    }
}

extension ProfileViewControllerV2: ProfilePresenterOutput {
    func display(profile: APIClient.Profile) {
        setBasicInfo(profile)

        if let following = profile.isFollowing, following == true {
            followButton.isSelected.toggle()
        }

        followsYouBadge.isHidden = true
        if let followed = profile.followedBy {
            followsYouBadge.isHidden = !followed
        }
    }

    func display(personal profile: APIClient.Profile) {
        setBasicInfo(profile)

        followButton.setTitle(NSLocalizedString("edit", comment: ""), for: .normal)
        followsYouBadge.isHidden = true
    }

    private func setBasicInfo(_ profile: APIClient.Profile) {
        id = profile.id
        displayName.text = profile.displayName
        username.text = "@" + profile.username
        followersCountLabel.text = String(profile.followers)
        followingCountLabel.text = String(profile.following)

        if profile.image != "" {
            image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + profile.image))
        }
    }
}
