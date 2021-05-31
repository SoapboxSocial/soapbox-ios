import AlamofireImage
import GSImageViewerController
import UIKit
import SwiftUI

protocol ProfileViewControllerOutput {
    func loadData()
    func follow()
    func unfollow()
    func block()
    func unblock()
}

class ProfileViewController: ViewControllerWithRemoteContent<APIClient.Profile> {
    private var stories: [APIClient.Story]?

    var output: ProfileViewControllerOutput!

    private let stack: UIStackView = {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background
        
        let childView = UIHostingController(rootView: ProfileView())
        addChild(childView)
        childView.view.frame = view.frame
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
        
        contentView.addSubview(stack)

        headerView.button.setTitle(NSLocalizedString("follow", comment: ""), for: .normal)
        headerView.button.setTitle(NSLocalizedString("following", comment: ""), for: .selected)
        headerView.button.isHidden = false
        headerView.descriptionLabel.font = .rounded(forTextStyle: .body, weight: .regular)
        stack.addArrangedSubview(headerView)

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
        stack.addArrangedSubview(statistics)

        NSLayoutConstraint.activate([
            headerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            headerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            stack.rightAnchor.constraint(equalTo: contentView.rightAnchor),
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
        stack.addArrangedSubview(badges)

        NSLayoutConstraint.activate([
            twitter.topAnchor.constraint(equalTo: badges.topAnchor),
            twitter.leftAnchor.constraint(equalTo: badges.leftAnchor),
        ])

        NSLayoutConstraint.activate([
            badges.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            badges.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            badges.bottomAnchor.constraint(equalTo: twitter.bottomAnchor),
        ])

        output.loadData()
    }

    @objc override func loadData() {
        super.loadData()
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

        let sheet = ActionSheet()

        // @TODO only show action when not in room

        sheet.add(action: ActionSheet.Action(title: NSLocalizedString("view_image", comment: ""), style: .default, handler: { _ in
            presentImage()
        }))

        sheet.add(action: ActionSheet.Action(title: NSLocalizedString("listen_to_story", comment: ""), style: .default, handler: { _ in
            guard let nav = UIApplication.shared.keyWindow?.rootViewController as? NavigationViewController else {
                return
            }

            if nav.room != nil {
                let banner = NotificationBanner(title: NSLocalizedString("cant_listen_in_room", comment: ""), style: .info, type: .floating)
                banner.show()
                return
            }

            let vc = StoriesViewController(
                feed: APIClient.StoryFeed(
                    user: APIClient.User(
                        id: self.content.id,
                        displayName: self.content.displayName,
                        username: self.content.username,
                        email: nil,
                        image: self.content.image
                    ),
                    stories: stories
                )
            )

            vc.modalPresentationStyle = .fullScreen

            self.present(vc, animated: true)
        }))

        sheet.add(action: ActionSheet.Action(title: NSLocalizedString("cancel", comment: ""), style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func openTwitterProfile() {
        guard let account = content.linkedAccounts.first(where: { $0.provider == "twitter" }) else {
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
        let list = SceneFactory.createUserViewController(id: content.id, title: NSLocalizedString("followers", comment: ""), userListFunc: APIClient().followers)
        navigationController?.pushViewController(list, animated: true)
    }

    @objc private func didTapFollowingLabel() {
        let list = SceneFactory.createUserViewController(id: content.id, title: NSLocalizedString("following", comment: ""), userListFunc: APIClient().following)
        navigationController?.pushViewController(list, animated: true)
    }

    @objc private func editPressed() {
        let vc = EditProfileViewController(user: content, parent: self)
        present(vc, animated: true)
    }

    @objc private func followPressed() {
        headerView.button.isLoading = true

        if content.isBlocked ?? false {
            let sheet = ActionSheet()

            let fmt = NSLocalizedString("unblock_user", comment: "")

            sheet.add(action: ActionSheet.Action(title: String(format: fmt, "@" + content.username), style: .destructive, handler: { _ in
                self.output.unblock()
            }))

            sheet.add(action: ActionSheet.Action(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: { _ in
                self.headerView.button.isLoading = false
            }))

            present(sheet, animated: true)
            return
        }

        if content.isFollowing ?? false {
            let sheet = ActionSheet()

            let fmt = NSLocalizedString("unfollow_user", comment: "")

            sheet.add(action: ActionSheet.Action(title: String(format: fmt, "@" + content.username), style: .destructive, handler: { _ in
                self.output.unfollow()
                DispatchQueue.main.async {
                    self.headerView.button.isLoading = true
                }
            }))

            sheet.add(action: ActionSheet.Action(title: NSLocalizedString("cancel", comment: ""), style: .cancel))

            sheet.willDismissHandler = {
                self.headerView.button.isLoading = false
            }

            present(sheet, animated: true)
        } else {
            output.follow()
        }
    }

    @objc private func menuButtonPressed() {
        let sheet = ActionSheet()

        sheet.add(action: ActionSheet.Action(title: NSLocalizedString("share_profile", comment: ""), style: .default, handler: { _ in
            let items: [Any] = [
                URL(string: "https://soap.link/@" + self.content.username)!,
            ]

            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            ac.excludedActivityTypes = [.markupAsPDF, .openInIBooks, .addToReadingList, .assignToContact]

            DispatchQueue.main.async {
                self.present(ac, animated: true)
            }
        }))

        let id = UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId)

        if content.id == id {
            sheet.add(action: ActionSheet.Action(title: NSLocalizedString("settings", comment: ""), style: .default, handler: { _ in
                self.navigationController?.pushViewController(SceneFactory.createSettingsViewController(), animated: true)
            }))
        } else {
            sheet.add(action: ActionSheet.Action(title: NSLocalizedString("report_incident", comment: ""), style: .destructive, handler: { _ in
                let view = ReportPageViewController(
                    userId: UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId),
                    reportedUserId: self.content.id
                )

                DispatchQueue.main.async {
                    self.present(view, animated: true)
                }
            }))

            var blockedLabel = NSLocalizedString("block", comment: "")
            var blockedDescription = NSLocalizedString("block_description", comment: "")
            if content.isBlocked ?? false {
                blockedLabel = NSLocalizedString("unblock", comment: "")
                blockedDescription = ""
            }

            sheet.add(action: ActionSheet.Action(title: blockedLabel, style: .destructive, handler: { _ in
                let confirmation = UIAlertController.confirmation(
                    onAccepted: {
                        if self.content.isBlocked ?? false {
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
        }

        sheet.add(action: ActionSheet.Action(title: NSLocalizedString("cancel", comment: ""), style: .cancel))
        present(sheet, animated: true)
    }
}

extension ProfileViewController: ProfilePresenterOutput {
    func displayError(title: String, description: String?) {
        let banner = NotificationBanner(
            title: title,
            subtitle: description,
            style: .danger,
            type: .floating
        )

        banner.show()
    }

    func display(profile: APIClient.Profile) {
        setBasicInfo(profile)

        if let following = profile.isFollowing {
            headerView.button.isSelected = following
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
    }

    func display(personal profile: APIClient.Profile) {
        setBasicInfo(profile)

        headerView.button.setTitle(NSLocalizedString("edit", comment: ""), for: .normal)
        headerView.button.addTarget(self, action: #selector(editPressed), for: .touchUpInside)
        followsYouBadge.isHidden = true
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
        headerView.button.isLoading = false
        headerView.button.isSelected.toggle()
        content.isFollowing = true
        content.followers += 1
        updateFollowerLabels()
    }

    func didUnfollow() {
        headerView.button.isLoading = false
        headerView.button.isSelected.toggle()
        content.isFollowing = false
        content.followers -= 1
        updateFollowerLabels()
    }

    func didBlock() {
        headerView.button.isLoading = false
        content.isBlocked = true
        content.isFollowing = false

        if content.followers > 0 {
            content.followers -= 1
        }

        updateFollowerLabels()

        followsYouBadge.isHidden = true

        headerView.button.isSelected = false
        headerView.button.backgroundColor = .systemRed
        headerView.button.setTitle(NSLocalizedString("blocked", comment: ""), for: .normal)
    }

    func didUnblock() {
        headerView.button.isLoading = false
        content.isBlocked = false
        content.isFollowing = false

        headerView.button.backgroundColor = .brandColor
        headerView.button.setTitle(NSLocalizedString("follow", comment: ""), for: .normal)
        headerView.button.isSelected = false
    }

    private func updateFollowerLabels() {
        followersCount.statistic.text = String(content.followers)
        if content.followers == 1 {
            followersCount.descriptionLabel.text = NSLocalizedString("follower", comment: "")
        } else {
            followersCount.descriptionLabel.text = NSLocalizedString("followers", comment: "")
        }
    }

    private func setBasicInfo(_ profile: APIClient.Profile) {
        didLoad(content: profile)
        title = profile.username
        headerView.titleLabel.text = profile.displayName
        headerView.descriptionLabel.text = profile.bio
        followingCount.statistic.text = String(profile.following)

        if content.linkedAccounts.first(where: { $0.provider == "twitter" }) != nil {
            badges.isHidden = false
        } else {
            badges.isHidden = true
        }

        updateFollowerLabels()

        if profile.image != "" {
            headerView.image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + profile.image))
            headerView.image.contentMode = .scaleAspectFill
        }

        var image = "ellipsis"
        if profile.id == UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId) {
            image = "gearshape"
        }

        let item = UIBarButtonItem(
            image: UIImage(systemName: image),
            style: .plain,
            target: self,
            action: #selector(menuButtonPressed)
        )

        navigationItem.rightBarButtonItem = item
    }
}
