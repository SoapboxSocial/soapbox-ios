import AlamofireImage
import FocusableImageView
import NotificationBannerSwift
import UIKit

protocol ProfileViewControllerOutput {
    func loadData()
    func follow()
    func unfollow()
}

class ProfileViewController: UIViewController {
    private var user: APIClient.Profile!

    var output: ProfileViewControllerOutput!

    private let image: FocusableImageView = {
        let image = FocusableImageView()
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

    private let followButton: Button = {
        let button = Button(size: .small)
        button.setTitle(NSLocalizedString("follow", comment: ""), for: .normal)
        button.setTitle(NSLocalizedString("unfollow", comment: ""), for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let followersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .body, weight: .regular)
        return label
    }()

    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = .rounded(forTextStyle: .body, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private let twitter: TwitterBadge = {
        let badge = TwitterBadge()
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.isUserInteractionEnabled = true
        return badge
    }()

    private let downloader = ImageDownloader()
    private lazy var manager = FocusableImageViewManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        FocusableImageViewConfiguration.default = .init(
            backgroundColor: .init(white: 0, alpha: 0.5),
            animationDuration: 0.5,
            pageControlConfiguration: .init(hidesForSinglePage: true, pageIndicatorTintColor: nil, currentPageIndicatorTintColor: nil),
            maximumZoomScale: 2
        )

        manager.delegate = self

        view.backgroundColor = .background

        output.loadData()

        view.addSubview(image)
        view.addSubview(displayName)
        view.addSubview(username)
        view.addSubview(followButton)
        view.addSubview(followsYouBadge)
        view.addSubview(twitter)

        twitter.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openTwitterProfile)))

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

        view.addSubview(bioLabel)

        NSLayoutConstraint.activate([
            image.heightAnchor.constraint(equalToConstant: 80),
            image.widthAnchor.constraint(equalToConstant: 80),
            image.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            image.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            followButton.bottomAnchor.constraint(equalTo: image.bottomAnchor),
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
            bioLabel.topAnchor.constraint(equalTo: username.bottomAnchor, constant: 20),
            bioLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            bioLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            followsYouLabel.topAnchor.constraint(equalTo: followsYouBadge.topAnchor),
            followsYouLabel.leftAnchor.constraint(equalTo: followsYouBadge.leftAnchor, constant: 8),
            followsYouLabel.rightAnchor.constraint(equalTo: followsYouBadge.rightAnchor, constant: -8),
            followsYouLabel.bottomAnchor.constraint(equalTo: followsYouBadge.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            followersView.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 20),
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
            followingView.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 20),
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

        NSLayoutConstraint.activate([
            twitter.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            twitter.topAnchor.constraint(equalTo: followersView.bottomAnchor, constant: 20),
        ])
    }

    @objc private func openTwitterProfile() {
        guard let account = user.linkedAccounts.first(where: { $0.provider == "twitter" }) else {
            return
        }

        let appURL = URL(string: "twitter://user?screen_name=\(account.username)")!
        let webURL = URL(string: "https://twitter.com/\(account.username)")!

        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else {
            UIApplication.shared.open(webURL)
        }
    }

    // @TODO THIS SHOULD BE DONE THROUGH INTERACTOR FLOW
    @objc private func didTapFollowersLabel() {
        let list = SceneFactory.createUserViewController(id: user.id, title: NSLocalizedString("followers", comment: ""), userListFunc: APIClient().followers)
        navigationController?.pushViewController(list, animated: true)
    }

    @objc private func didTapFollowingLabel() {
        let list = SceneFactory.createUserViewController(id: user.id, title: NSLocalizedString("following", comment: ""), userListFunc: APIClient().following)
        navigationController?.pushViewController(list, animated: true)
    }

    @objc private func editPressed() {
        let vc = EditProfileViewController(user: user, parent: self)
        present(vc, animated: true)
    }

    @objc private func followPressed() {
        followButton.isUserInteractionEnabled = false

        if user.isFollowing ?? false {
            output.unfollow()
        } else {
            output.follow()
        }
    }
}

extension ProfileViewController: ProfilePresenterOutput {
    func displayError(title: String, description: String?) {
        let banner = FloatingNotificationBanner(
            title: title,
            subtitle: description,
            style: .danger
        )

        banner.show(cornerRadius: 10, shadowBlurRadius: 15)
    }

    func display(profile: APIClient.Profile) {
        setBasicInfo(profile)

        if let following = profile.isFollowing, following == true {
            followButton.isSelected.toggle()
        }

        followsYouBadge.isHidden = true
        if let followed = profile.followedBy {
            followsYouBadge.isHidden = !followed
        }

        followButton.addTarget(self, action: #selector(followPressed), for: .touchUpInside)
    }

    func display(personal profile: APIClient.Profile) {
        setBasicInfo(profile)

        followButton.setTitle(NSLocalizedString("edit", comment: ""), for: .normal)
        followButton.addTarget(self, action: #selector(editPressed), for: .touchUpInside)
        followsYouBadge.isHidden = true
    }

    func didFollow() {
        followButton.isUserInteractionEnabled = true
        followButton.isSelected.toggle()
        user.isFollowing = true
        user.followers += 1
        updateFollowerLabels()
    }

    func didUnfollow() {
        followButton.isUserInteractionEnabled = true
        followButton.isSelected.toggle()
        user.isFollowing = false
        user.followers -= 1
        updateFollowerLabels()
    }

    private func updateFollowerLabels() {
        followersCountLabel.text = String(user.followers)
        if user.followers == 1 {
            followersLabel.text = NSLocalizedString("follower", comment: "")
        } else {
            followersLabel.text = NSLocalizedString("followers", comment: "")
        }
    }

    private func setBasicInfo(_ profile: APIClient.Profile) {
        user = profile
        displayName.text = profile.displayName
        username.text = "@" + profile.username
        followingCountLabel.text = String(profile.following)
        bioLabel.text = profile.bio
        title = profile.username

        if user.linkedAccounts.first(where: { $0.provider == "twitter" }) != nil {
            twitter.isHidden = false
        } else {
            twitter.isHidden = true
        }

        updateFollowerLabels()

        if profile.image != "" {
            image.inner.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + profile.image))
            image.inner.contentMode = .scaleAspectFill
            manager.register(parentViewController: self, imageViews: [image])
        }
    }
}

extension ProfileViewController: FocusableImageViewDelegate {
    func focusableImageViewPresentAnimation(views: [FocusableImageView]) {
        views.forEach { $0.inner.layer.cornerRadius = 0 }
    }

    func focusableImageViewDismissAnimation(views: [FocusableImageView]) {
        views.forEach { $0.inner.layer.cornerRadius = 8 }
    }
}
