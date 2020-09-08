import AlamofireImage
import NotificationBannerSwift
import UIKit

class ProfileViewController: UIViewController {
    private let api = APIClient()
    private let id: Int
    private var user: APIClient.Profile!

    private var followButton: Button!
    private var followersLabel: UILabel!
    private var followingLabel: UILabel!
    private var followsYou: UILabel!

    private var image: UIImageView!
    private var name: UILabel!
    private var username: UILabel!

    private var editButton: Button!
    private var currentRoom: CurrentRoomView!

    init(id: Int) {
        self.id = id
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()

        view.backgroundColor = .background

        loadData()
    }

    func loadData() {
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

        name.text = user.displayName
        username.text = "@" + user.username

        updateFollowersLabelText(count: user.followers)

        followingLabel.text = String(user.following) + " " + NSLocalizedString("following", comment: "")
        image.af.setImage(withURL: Configuration.cdn.appendingPathComponent("/images/" + user.image))

        currentRoom.displayName = user.displayName

        if self.user.id != UserDefaults.standard.integer(forKey: "id") {
            editButton.isHidden = true

            followButton.isHidden = false
            updateFollowButtonLabel()

            if user.followedBy ?? false {
                followsYou.isHidden = false
            }

            if user.currentRoom != nil, user.currentRoom != 0 {
                currentRoom.isHidden = false
                currentRoom.isUserInteractionEnabled = true
            }
        } else {
            // @todo this is a hacky way to refresh the user after update.
            UserStore.store(user:
                APIClient.User(
                    id: user.id,
                    displayName: user.displayName,
                    username: user.username,
                    email: UserDefaults.standard.string(forKey: "email") ?? "",
                    image: user.image
                ))

            editButton.isHidden = false
            followButton.isHidden = true
            followsYou.isHidden = true
        }
    }

    private func setup() {
        guard let navigation = navigationController else {
            return
        }

        let bar = navigation.navigationBar

        let margin = CGFloat(16.0)

        image = UIImageView(frame: CGRect(x: margin, y: bar.frame.origin.y + bar.frame.size.height + 20, width: 80, height: 80))
        image.layer.cornerRadius = image.frame.size.width / 2
        image.backgroundColor = .secondaryBackground
        image.clipsToBounds = true
        view.addSubview(image)

        let offset = image.frame.origin.x + image.frame.size.width + 20
        name = UILabel(frame: CGRect(x: offset, y: image.frame.origin.y, width: view.frame.size.width - offset, height: 20))
        name.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        name.textColor = .black
        name.textAlignment = .left
        view.addSubview(name)

        username = UILabel(frame: CGRect(x: name.frame.origin.x, y: name.frame.origin.y + name.frame.size.height, width: view.frame.size.width - 80, height: 20))
        username.textColor = .black
        view.addSubview(username)

        followersLabel = UILabel(frame: CGRect(x: image.frame.origin.x, y: image.frame.origin.y + image.frame.size.height + margin, width: 100, height: 20))
        followersLabel.font = username.font
        followersLabel.textColor = .black
        view.addSubview(followersLabel)

        let followersRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapFollowersLabel))
        followersLabel.addGestureRecognizer(followersRecognizer)
        followersLabel.isUserInteractionEnabled = true

        followingLabel = UILabel(frame: CGRect(x: followersLabel.frame.size.width + followersLabel.frame.origin.x + 10, y: followersLabel.frame.origin.y, width: 100, height: 20))
        followingLabel.font = username.font
        followingLabel.textColor = .black
        view.addSubview(followingLabel)

        let followingRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapFollowingLabel))
        followingLabel.addGestureRecognizer(followingRecognizer)
        followingLabel.isUserInteractionEnabled = true

        followsYou = UILabel(frame: CGRect(x: username.frame.origin.x, y: image.frame.origin.y + image.frame.size.height - 20, width: view.frame.size.width - 80, height: 20))
        followsYou.textColor = .gray
        followsYou.text = NSLocalizedString("follows_you", comment: "")
        view.addSubview(followsYou)
        followsYou.sizeToFit()

        followsYou.isHidden = true

        followButton = Button(frame: CGRect(x: view.frame.size.width - (100 + margin), y: 0, width: 100, height: 30))
        followButton.center = CGPoint(x: followButton.center.x, y: followsYou.center.y)
        followButton.addTarget(self, action: #selector(followButtonPressed), for: .touchUpInside)
        view.addSubview(followButton)

        editButton = Button(frame: followButton.frame)
        editButton.addTarget(self, action: #selector(editButtonPressed), for: .touchUpInside)
        editButton.setTitle("Edit", for: .normal)
        view.addSubview(editButton)

        currentRoom = CurrentRoomView(frame: CGRect(x: 15, y: followersLabel.frame.origin.y + followersLabel.frame.size.height + 20, width: view.frame.size.width - 30, height: 90))
        view.addSubview(currentRoom)
        let currentRoomRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapCurrentRoom))
        currentRoom.addGestureRecognizer(currentRoomRecognizer)
        currentRoom.isHidden = true
        currentRoom.isUserInteractionEnabled = false
    }

    @objc private func didTapCurrentRoom() {
        guard let navigation = navigationController as? NavigationViewController else {
            return
        }

        guard let room = user.currentRoom else {
            return
        }

        navigation.didSelectRoom(id: room)
    }

    @objc private func editButtonPressed() {
        let vc = EditProfileViewController(user: user, parent: self)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
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
