import AlamofireImage
import FocusableImageView
import NotificationBannerSwift
import UIKit

protocol ProfileViewControllerOutput {
    func loadData()
    func follow()
    func unfollow()
    func loadMoreGroups()
}

class ProfileViewController: ViewController {
    private var user: APIClient.Profile!

    var output: ProfileViewControllerOutput!

    private let content: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 20
        view.distribution = .fill
        view.alignment = .fill
        view.axis = .vertical
        return view
    }()

    private var headerView: ProfileHeaderView = {
        ProfileHeaderView()
    }()

    private let followersCount: StatisticView = {
        let view = StatisticView()
        view.descriptionLabel.text = NSLocalizedString("followers", comment: "")
        return view
    }()

    private let followingCount: StatisticView = {
        let view = StatisticView()
        view.descriptionLabel.text = NSLocalizedString("following", comment: "")
        return view
    }()

    private let followsYouBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()

    private let groupsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let badges: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let twitter: TwitterBadge = {
        let badge = TwitterBadge()
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.isUserInteractionEnabled = true
        return badge
    }()

    private let groups: GroupsSlider = {
        let view = GroupsSlider()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var manager = FocusableImageViewManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        scrollView.addSubview(content)

        headerView.button.setTitle(NSLocalizedString("follow", comment: ""), for: .normal)
        headerView.button.setTitle(NSLocalizedString("unfollow", comment: ""), for: .selected)
        headerView.button.isHidden = false
        headerView.descriptionLabel.font = .rounded(forTextStyle: .body, weight: .regular)
        content.addArrangedSubview(headerView)

        let followsYouLabel = UILabel()
        followsYouLabel.translatesAutoresizingMaskIntoConstraints = false
        followsYouLabel.font = .rounded(forTextStyle: .body, weight: .semibold)
        followsYouLabel.textColor = .systemGray2
        followsYouLabel.text = NSLocalizedString("follows_you", comment: "")
        followsYouBadge.addSubview(followsYouLabel)
        headerView.addSubview(followsYouBadge)

        NSLayoutConstraint.activate([
            followsYouBadge.centerYAnchor.constraint(equalTo: headerView.button.centerYAnchor),
            followsYouBadge.rightAnchor.constraint(equalTo: headerView.button.leftAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            followsYouLabel.topAnchor.constraint(equalTo: followsYouBadge.topAnchor),
            followsYouLabel.leftAnchor.constraint(equalTo: followsYouBadge.leftAnchor, constant: 8),
            followsYouLabel.rightAnchor.constraint(equalTo: followsYouBadge.rightAnchor, constant: -8),
            followsYouLabel.bottomAnchor.constraint(equalTo: followsYouBadge.bottomAnchor),
        ])

        let statistics = UIView()
        statistics.translatesAutoresizingMaskIntoConstraints = false
        statistics.addSubview(followersCount)
        statistics.addSubview(followingCount)
        content.addArrangedSubview(statistics)

        NSLayoutConstraint.activate([
            headerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            headerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
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

        NSLayoutConstraint.activate([
            followersCount.topAnchor.constraint(equalTo: statistics.topAnchor),
            followersCount.leftAnchor.constraint(equalTo: statistics.leftAnchor),
        ])

        NSLayoutConstraint.activate([
            followingCount.topAnchor.constraint(equalTo: statistics.topAnchor),
            followingCount.leftAnchor.constraint(equalTo: followersCount.rightAnchor, constant: 40),
        ])

        followingCount.handleTap(target: self, action: #selector(didTapFollowingLabel))
        followersCount.handleTap(target: self, action: #selector(didTapFollowersLabel))

        NSLayoutConstraint.activate([
            statistics.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            statistics.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            statistics.bottomAnchor.constraint(equalTo: followingCount.bottomAnchor),
        ])

        twitter.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openTwitterProfile)))

        badges.addSubview(twitter)
        content.addArrangedSubview(badges)

        NSLayoutConstraint.activate([
            twitter.topAnchor.constraint(equalTo: badges.topAnchor),
            twitter.leftAnchor.constraint(equalTo: badges.leftAnchor),
        ])

        NSLayoutConstraint.activate([
            badges.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            badges.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            badges.bottomAnchor.constraint(equalTo: twitter.bottomAnchor),
        ])

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title2, weight: .bold)
        label.text = NSLocalizedString("groups", comment: "")
        groupsContainer.addSubview(label)

        groups.delegate = self
        groupsContainer.addSubview(groups)
        groupsContainer.isHidden = true

        content.addArrangedSubview(groupsContainer)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: groupsContainer.topAnchor),
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            groupsContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            groupsContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            groupsContainer.bottomAnchor.constraint(equalTo: groups.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            groups.heightAnchor.constraint(equalToConstant: 82),
            groups.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            groups.leftAnchor.constraint(equalTo: groupsContainer.leftAnchor),
            groups.rightAnchor.constraint(equalTo: groupsContainer.rightAnchor),
        ])

        output.loadData()
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
        headerView.button.isUserInteractionEnabled = false

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
            headerView.button.isSelected.toggle()
        }

        followsYouBadge.isHidden = true
        if let followed = profile.followedBy {
            followsYouBadge.isHidden = !followed
        }

        headerView.button.addTarget(self, action: #selector(followPressed), for: .touchUpInside)
    }

    func display(personal profile: APIClient.Profile) {
        setBasicInfo(profile)

        headerView.button.setTitle(NSLocalizedString("edit", comment: ""), for: .normal)
        headerView.button.addTarget(self, action: #selector(editPressed), for: .touchUpInside)
        followsYouBadge.isHidden = true
        groupsContainer.isHidden = false
        groups.allowCreation = true
    }

    func display(groups: [APIClient.Group]) {
        if groups.isEmpty {
            groupsContainer.isHidden = true
            return
        }

        groupsContainer.isHidden = false
        self.groups.set(groups: groups)
    }

    func display(moreGroups groups: [APIClient.Group]) {
        self.groups.set(groups: groups)
    }

    func didFollow() {
        headerView.button.isUserInteractionEnabled = true
        headerView.button.isSelected.toggle()
        user.isFollowing = true
        user.followers += 1
        updateFollowerLabels()
    }

    func didUnfollow() {
        headerView.button.isUserInteractionEnabled = true
        headerView.button.isSelected.toggle()
        user.isFollowing = false
        user.followers -= 1
        updateFollowerLabels()
    }

    private func updateFollowerLabels() {
        followersCount.statistic.text = String(user.followers)
        if user.followers == 1 {
            followersCount.descriptionLabel.text = NSLocalizedString("follower", comment: "")
        } else {
            followersCount.descriptionLabel.text = NSLocalizedString("followers", comment: "")
        }
    }

    private func setBasicInfo(_ profile: APIClient.Profile) {
        user = profile
        title = profile.username
        headerView.titleLabel.text = profile.displayName
        headerView.descriptionLabel.text = profile.bio
        followingCount.statistic.text = String(profile.following)

        if user.linkedAccounts.first(where: { $0.provider == "twitter" }) != nil {
            badges.isHidden = false
        } else {
            badges.isHidden = true
        }

        updateFollowerLabels()

        if profile.image != "" {
            headerView.image.inner.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + profile.image))
            headerView.image.inner.contentMode = .scaleAspectFill
            manager.register(parentViewController: self, imageViews: [headerView.image])
        }
    }
}

extension ProfileViewController: GroupsSliderDelegate {
    func loadMoreGroups() {
        output.loadMoreGroups()
    }

    func didSelect(group: Int) {
        navigationController?.pushViewController(SceneFactory.createGroupViewController(id: group), animated: true)
    }

    func didTapGroupCreation() {
        present(SceneFactory.createGroupCreationViewController(), animated: true)
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
