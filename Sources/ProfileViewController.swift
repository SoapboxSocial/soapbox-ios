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

        let name = UILabel(frame: CGRect(x: 40, y: image.frame.origin.y + image.frame.size.height + 20, width: 100, height: 20))
        name.text = user.displayName
        name.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        name.textColor = .black
        view.addSubview(name)

        let username = UILabel(frame: CGRect(x: 40, y: name.frame.origin.y + name.frame.size.height, width: view.frame.size.width - 80, height: 20))
        username.text = "@" + user.username
        username.textColor = .black
        view.addSubview(username)

        let followers = UILabel(frame: CGRect(x: 40, y: username.frame.origin.y + username.frame.size.height + 40, width: 100, height: 20))
        followers.text = followerLabel(count: user.followers)
        followers.font = username.font
        followers.textColor = .black
        view.addSubview(followers)

        let following = UILabel(frame: CGRect(x: followers.frame.size.width + followers.frame.origin.x + 10, y: username.frame.origin.y + username.frame.size.height + 40, width: 100, height: 20))
        following.text = String(user.following) + " " + NSLocalizedString("following", comment: "")
        following.font = username.font
        following.textColor = .black
        view.addSubview(following)
        
        if self.user.id != UserDefaults.standard.integer(forKey: "id") {
            if user.followedBy ?? false {
                let followsYou = UILabel(frame: CGRect(x: name.frame.origin.x + name.frame.size.width + 30, y: name.frame.origin.y, width: 100, height: 20))
                followsYou.text = NSLocalizedString("follows_you", comment: "")
                view.addSubview(followsYou)
            }

            followButton = Button(frame: CGRect(x: view.frame.size.width - 140, y: image.frame.origin.y + (image.frame.size.height / 2) - 15, width: 100, height: 30))
            followButton.addTarget(self, action: #selector(followButtonPressed), for: .touchUpInside)
            updateFollowButtonLabel()
            view.addSubview(followButton)
        }
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
                        self.user.isFollowing = true
                        self.updateFollowButtonLabel()
                    }
                }

            })
        }
    }
    
    private func updateFollowButtonLabel() {
        if user.isFollowing ?? false {
            self.followButton.setTitle(NSLocalizedString("unfollow", comment: ""), for: .normal)
        } else {
            self.followButton.setTitle(NSLocalizedString("follow", comment: ""), for: .normal)
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
    
    private func followerLabel(count: Int) -> String {
        if count == 1 {
            return String(count) + " " + NSLocalizedString("follower", comment: "")
        }
        
        return String(count) + " " + NSLocalizedString("followers", comment: "")
    }
}
