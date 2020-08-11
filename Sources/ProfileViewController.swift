//
//  ProfileViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 06.08.20.
//

import NotificationBannerSwift
import UIKit

class ProfileViewController: UIViewController {
    private let api = APIClient()
    private let id: Int
    private var user: APIClient.Profile!

    private var followButton: Button!
    private var followersLabel: UILabel!

    init(id: Int) {
        self.id = id
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        api.user(id: id) { result in
            switch result {
            case .failure:
                DispatchQueue.main.async {
                    self.displayErrorBanner()
                }
            case let .success(user):
                DispatchQueue.main.async {
                    self.setupView(user: user)
                }
            }
        }
    }

    private func setupView(user: APIClient.Profile) {
        self.user = user

        let image = UIView(frame: CGRect(x: 40, y: (navigationController?.navigationBar.frame.origin.y)! + (navigationController?.navigationBar.frame.size.height)! + 20, width: 75, height: 75))
        image.layer.cornerRadius = 75 / 2
        image.backgroundColor = .secondaryBackground
        view.addSubview(image)

        let name = UILabel(frame: CGRect(x: 40, y: image.frame.origin.y + image.frame.size.height + 20, width: 200, height: 20))
        name.text = user.displayName
        name.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        name.textColor = .black
        view.addSubview(name)

        let username = UILabel(frame: CGRect(x: 40, y: name.frame.origin.y + name.frame.size.height, width: view.frame.size.width - 80, height: 20))
        username.text = "@" + user.username
        username.textColor = .black
        view.addSubview(username)

        followersLabel = UILabel(frame: CGRect(x: 40, y: username.frame.origin.y + username.frame.size.height + 40, width: 100, height: 20))
        updateFollowersLabelText(count: user.followers)
        followersLabel.font = username.font
        followersLabel.textColor = .black
        view.addSubview(followersLabel)

        let followersRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapFollowersLabel))
        followersLabel.addGestureRecognizer(followersRecognizer)
        followersLabel.isUserInteractionEnabled = true

        let followingLabel = UILabel(frame: CGRect(x: followersLabel.frame.size.width + followersLabel.frame.origin.x + 10, y: username.frame.origin.y + username.frame.size.height + 40, width: 100, height: 20))
        followingLabel.font = username.font
        followingLabel.textColor = .black
        followingLabel.text = String(user.following) + " " + NSLocalizedString("following", comment: "")
        view.addSubview(followingLabel)

        let followingRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapFollowingLabel))
        followingLabel.addGestureRecognizer(followingRecognizer)
        followingLabel.isUserInteractionEnabled = true

        if self.user.id != UserDefaults.standard.integer(forKey: "id") {
            followButton = Button(frame: CGRect(x: view.frame.size.width - 140, y: image.frame.origin.y + (image.frame.size.height / 2) - 15, width: 100, height: 30))
            followButton.addTarget(self, action: #selector(followButtonPressed), for: .touchUpInside)
            updateFollowButtonLabel()
            view.addSubview(followButton)

            if user.followedBy ?? false {
                let followsYou = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
                followsYou.text = NSLocalizedString("follows_you", comment: "")
                view.addSubview(followsYou)
                followsYou.sizeToFit()

                followsYou.frame = CGRect(
                    origin: CGPoint(
                        x: followButton.frame.origin.x - followsYou.frame.size.width - 10,
                        y: followButton.center.y - (followsYou.frame.size.height / 2)
                    ),
                    size: followsYou.frame.size
                )
            }
        }
    }

    @objc private func didTapFollowingLabel() {
        let list = FollowerListViewController(id: id, userListFunc: api.following)
        navigationController?.pushViewController(list, animated: true)
    }

    @objc private func didTapFollowersLabel() {
        let list = FollowerListViewController(id: id, userListFunc: api.followers)
        navigationController?.pushViewController(list, animated: true)
    }

    @objc private func followButtonPressed() {
        // @todo update following label text
        if user.isFollowing ?? false {
            api.unfollow(id: user.id, callback: { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure:
                        self.displayErrorBanner()
                    case .success:
                        self.user.followers -= 1
                        self.updateFollowersLabelText(count: self.user.followers)
                        self.user.isFollowing = false
                        self.updateFollowButtonLabel()
                    }
                }
            })
        } else {
            api.follow(id: user.id, callback: { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure:
                        self.displayErrorBanner()
                    case .success:
                        self.user.followers += 1
                        self.updateFollowersLabelText(count: self.user.followers)
                        self.user.isFollowing = true
                        self.updateFollowButtonLabel()
                    }
                }

            })
        }
    }

    private func updateFollowButtonLabel() {
        if user.isFollowing ?? false {
            followButton.setTitle(NSLocalizedString("unfollow", comment: ""), for: .normal)
        } else {
            followButton.setTitle(NSLocalizedString("follow", comment: ""), for: .normal)
        }
    }

    private func displayErrorBanner() {
        let banner = FloatingNotificationBanner(
            title: NSLocalizedString("something_went_wrong", comment: ""),
            subtitle: NSLocalizedString("please_try_again_later", comment: ""),
            style: .danger
        )
        banner.show(cornerRadius: 10, shadowBlurRadius: 15)
    }

    private func updateFollowersLabelText(count: Int) {
        if count == 1 {
            followersLabel.text = String(count) + " " + NSLocalizedString("follower", comment: "")
            return
        }

        followersLabel.text = String(count) + " " + NSLocalizedString("followers", comment: "")
    }
}
