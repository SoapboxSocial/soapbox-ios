import AlamofireImage
import GSImageViewerController
import NotificationBannerSwift
import UIKit

protocol ProfileViewControllerOutput {
    func loadData()
    func follow()
    func unfollow()
    func loadMoreGroups()
    func block()
    func unblock()
}

class ProfileViewController: ViewController {
    private var user: APIClient.Profile!

    private var stories: [APIClient.Story]?

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
        view.translatesAutoresizingMaskIntoConstraints = false

        let badge = UIView()
        badge.backgroundColor = .systemGray5
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.layer.cornerRadius = 5

        view.addSubview(badge)

        let followsYouLabel = UILabel()
        followsYouLabel.translatesAutoresizingMaskIntoConstraints = false
        followsYouLabel.font = .rounded(forTextStyle: .body, weight: .semibold)
        followsYouLabel.textColor = .systemGray2
        followsYouLabel.text = NSLocalizedString("follows_you", comment: "")
        badge.addSubview(followsYouLabel)

        NSLayoutConstraint.activate([
            badge.topAnchor.constraint(equalTo: view.topAnchor),
            view.bottomAnchor.constraint(equalTo: badge.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            followsYouLabel.topAnchor.constraint(equalTo: badge.topAnchor, constant: 2),
            followsYouLabel.leftAnchor.constraint(equalTo: badge.leftAnchor, constant: 8),
            followsYouLabel.rightAnchor.constraint(equalTo: badge.rightAnchor, constant: -8),
            followsYouLabel.bottomAnchor.constraint(equalTo: badge.bottomAnchor, constant: -2),
        ])

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

        let imageTap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        headerView.image.isUserInteractionEnabled = true
        headerView.image.addGestureRecognizer(imageTap)

        headerView.stack.insertArrangedSubview(followsYouBadge, at: 1)

        NSLayoutConstraint.activate([
            followsYouBadge.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            followsYouBadge.rightAnchor.constraint(equalTo: view.rightAnchor),
            followsYouBadge.bottomAnchor.constraint(equalTo: followsYouBadge.bottomAnchor),
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

    @objc private func didTapImage() {
        func presentImage() {
            guard let image = headerView.image.image else {
                return
            }

            let imageInfo = GSImageInfo(image: image, imageMode: .aspectFit)
            let transitionInfo = GSTransitionInfo(fromView: headerView.image)
            let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            present(imageViewer, animated: true)
        }

        guard let stories = stories else {
            return presentImage()
        }

        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )

        // @TODO only show action when not in room

        alert.addAction(UIAlertAction(title: NSLocalizedString("view_image", comment: ""), style: .default, handler: { _ in
            presentImage()
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("listen_to_story", comment: ""), style: .default, handler: { _ in
            guard let nav = UIApplication.shared.keyWindow?.rootViewController as? NavigationViewController else {
                return
            }

            if nav.room != nil {
                let banner = FloatingNotificationBanner(title: NSLocalizedString("cant_listen_in_room", comment: ""), style: .info)
                banner.show()
                return
            }

            let vc = StoriesViewController(
                feed: APIClient.StoryFeed(
                    user: APIClient.User(
                        id: self.user.id,
                        displayName: self.user.displayName,
                        username: self.user.username,
                        email: nil,
                        image: self.user.image
                    ),
                    stories: stories
                )
            )

            vc.modalPresentationStyle = .fullScreen

            self.present(vc, animated: true)
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel))

        present(alert, animated: true)
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

        if user.isBlocked ?? false {
            let alert = UIAlertController.confirmation(
                onAccepted: {
                    self.output.unblock()
                },
                onDeclined: {
                    self.headerView.button.isUserInteractionEnabled = true
                }
            )

            present(alert, animated: true)
            return
        }

        if user.isFollowing ?? false {
            let alert = UIAlertController.confirmation(
                onAccepted: {
                    self.output.unfollow()
                },
                onDeclined: {
                    self.headerView.button.isUserInteractionEnabled = true
                }
            )

            present(alert, animated: true)
        } else {
            output.follow()
        }
    }

    @objc private func menuButtonPressed() {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: NSLocalizedString("report_incident", comment: ""), style: .destructive, handler: { _ in
            let view = ReportPageViewController(
                userId: UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId),
                reportedUserId: self.user.id
            )

            DispatchQueue.main.async {
                self.present(view, animated: true)
            }
        }))

        var blockedLabel = NSLocalizedString("block", comment: "")
        var blockedDescription = NSLocalizedString("block_description", comment: "")
        if user.isBlocked ?? false {
            blockedLabel = NSLocalizedString("unblock", comment: "")
            blockedDescription = ""
        }

        alert.addAction(UIAlertAction(title: blockedLabel, style: .destructive, handler: { _ in
            let confirmation = UIAlertController.confirmation(
                onAccepted: {
                    if self.user.isBlocked ?? false {
                        self.output.unblock()
                        return
                    }

                    self.output.block()
                },
                message: blockedDescription
            )

            DispatchQueue.main.async {
                self.present(confirmation, animated: true)
            }
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel))

        present(alert, animated: true)
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

        if profile.isBlocked ?? false {
            headerView.button.isSelected = false
            headerView.button.backgroundColor = .systemRed
            headerView.button.setTitle(NSLocalizedString("blocked", comment: ""), for: .normal)
        }

        headerView.button.addTarget(self, action: #selector(followPressed), for: .touchUpInside)

        let item = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(menuButtonPressed)
        )

        navigationItem.rightBarButtonItem = item
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
            if user != nil, user.id != UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId) {
                groupsContainer.isHidden = true
            }

            return
        }

        groupsContainer.isHidden = false
        self.groups.set(groups: groups)
    }

    func display(moreGroups groups: [APIClient.Group]) {
        self.groups.set(groups: groups)
    }

    func display(stories: [APIClient.Story]) {
        if stories.isEmpty {
            return
        }

        self.stories = stories

        let frame = headerView.image.frame
        let width = CGFloat(5.0)

        let start = (3 * Double.pi) / 2
        let path = UIBezierPath(
            arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0),
            radius: (frame.size.width - width) / 2,
            startAngle: CGFloat(start),
            endAngle: CGFloat(start + (Double.pi * 2)),
            clockwise: true
        )

        let circleLayer = CAShapeLayer()
        circleLayer.path = path.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.brandColor.cgColor
        circleLayer.lineWidth = width

        circleLayer.strokeEnd = 0.0
        headerView.image.layer.addSublayer(circleLayer)

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1
        animation.fromValue = 0
        animation.toValue = 1

        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        circleLayer.strokeEnd = 1.0

        circleLayer.add(animation, forKey: "animateCircle")
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

    func didBlock() {
        headerView.button.isUserInteractionEnabled = true
        user.isBlocked = true
        user.isFollowing = false

        if user.followers > 0 {
            user.followers -= 1
        }

        updateFollowerLabels()

        followsYouBadge.isHidden = true

        headerView.button.isSelected = false
        headerView.button.backgroundColor = .systemRed
        headerView.button.setTitle(NSLocalizedString("blocked", comment: ""), for: .normal)
    }

    func didUnblock() {
        headerView.button.isUserInteractionEnabled = true
        user.isBlocked = false
        user.isFollowing = false

        headerView.button.backgroundColor = .brandColor
        headerView.button.setTitle(NSLocalizedString("follow", comment: ""), for: .normal)
        headerView.button.isSelected = false
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
            headerView.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + profile.image))
            headerView.image.contentMode = .scaleAspectFill
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
