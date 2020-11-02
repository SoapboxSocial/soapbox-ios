import AVFoundation
import DrawerView
import NotificationBannerSwift
import UIKit

protocol RoomViewDelegate {
    func roomWasClosedDueToError()
    func roomDidExit()
    func didSelectViewProfile(id: Int)
}

class RoomView: UIView {
    var delegate: RoomViewDelegate?

    let room: Room

    private let topBarHeight: CGFloat

    private var muteButton: UIButton!
    private var members: UICollectionView!

    private var audioPlayer: AVAudioPlayer!

    private var roomNameLabel: UILabel!

    private var editNameButton: UIButton!
    private var inviteButton: UIButton!

    // @TODO MAKE THIS ITS OWN CLASS
    private var bottomBar: UIView!
    private var normalButtons: UIView!

    init(frame: CGRect, room: Room, topBarHeight: CGFloat) {
        self.room = room
        self.topBarHeight = topBarHeight
        super.init(frame: frame)
        room.delegate = self
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // @todo this is ugly but for a lack of a better place to put set up right now we put it here.
        if muteButton != nil {
            return
        }

        roundCorners(corners: [.topLeft, .topRight], radius: 25.0)

        let inset = safeAreaInsets.bottom

        let topBar = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: topBarHeight + inset))
        topBar.roundCorners(corners: [.topLeft, .topRight], radius: 25.0)
        addSubview(topBar)

        let handle = UIView(frame: CGRect(x: (frame.size.width / 2) - (36 / 2), y: 5, width: 36, height: 5))
        handle.backgroundColor = .systemGray5
        handle.layer.cornerRadius = 5 / 2
        topBar.addSubview(handle)

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(openBar))
        recognizer.numberOfTapsRequired = 1
        topBar.addGestureRecognizer(recognizer)

        let pasteLinkRecognizer = UITapGestureRecognizer(target: self, action: #selector(pasteLink))
        pasteLinkRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(pasteLinkRecognizer)

        let iconConfig = UIImage.SymbolConfiguration(weight: .medium)

        let exitButton = EmojiButton(
            frame: CGRect(x: frame.size.width - (36 + 20 + safeAreaInsets.left), y: (frame.size.height - inset) / 2 - 17.5, width: 36, height: 36)
        )
        exitButton.center = CGPoint(x: exitButton.center.x, y: topBar.center.y - (inset / 2))
        exitButton.setImage(UIImage(systemName: "xmark", withConfiguration: iconConfig), for: .normal)
        exitButton.tintColor = .systemRed
        exitButton.backgroundColor = .exitButtonBackground
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        addSubview(exitButton)

        muteButton = EmojiButton(frame: CGRect(x: exitButton.frame.origin.x - 56, y: 0, width: 36, height: 36))
        muteButton.setImage(UIImage(systemName: "mic", withConfiguration: iconConfig), for: .normal)
        muteButton.setImage(UIImage(systemName: "mic.slash", withConfiguration: iconConfig), for: .selected)
        muteButton.tintColor = .brandColor
        muteButton.center = CGPoint(x: muteButton.center.x, y: exitButton.center.y)
        muteButton.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)
        addSubview(muteButton)

        var offset = CGFloat(safeAreaInsets.left + 20)
        if room.visibility == .private {
            let lock = UIImageView(image: UIImage(systemName: "lock", withConfiguration: iconConfig))
            lock.tintColor = .label
            lock.frame = CGRect(x: offset, y: 0, width: 20, height: 20)
            lock.center = CGPoint(x: lock.center.x, y: exitButton.center.y)
            offset += 28 + 5
            addSubview(lock)
        }

        roomNameLabel = UILabel(frame: CGRect(x: offset, y: 0, width: muteButton.frame.origin.x - (offset + 20), height: 28))

        roomNameLabel.text = {
            if let name = room.name, name != "" {
                return name
            }

            return NSLocalizedString("current_room", comment: "")
        }()

        roomNameLabel.font = .rounded(forTextStyle: .title3, weight: .bold)
        roomNameLabel.center = CGPoint(x: roomNameLabel.center.x, y: exitButton.center.y)
        topBar.addSubview(roomNameLabel)

        let layout = UICollectionViewFlowLayout.basicUserBubbleLayout(itemsPerRow: 4, width: frame.size.width)
        members = UICollectionView(frame: CGRect(x: 0, y: topBar.frame.size.height, width: frame.size.width, height: frame.size.height - topBar.frame.size.height), collectionViewLayout: layout)
        members!.dataSource = self
        members!.delegate = self
        members!.register(cellWithClass: RoomMemberCell.self)
        members!.backgroundColor = .clear
        members!.layer.masksToBounds = false
        addSubview(members)

        let userId = UserDefaults.standard.integer(forKey: "id")

        bottomBar = UIView(frame: CGRect(x: (frame.size.width / 2) - (208 / 2), y: frame.size.height - (25 + 48 + safeAreaInsets.bottom), width: 208, height: 48))
        bottomBar.layer.cornerRadius = 48 / 2
        bottomBar.backgroundColor = .background
        addSubview(bottomBar)

        editNameButton = UIButton(
            frame: CGRect(x: 8, y: (48 / 2) - (36 / 2), width: 36, height: 36)
        )
        editNameButton.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: iconConfig), for: .normal)
        editNameButton.tintColor = .brandColor
        editNameButton.addTarget(self, action: #selector(editRoomNameButtonTapped), for: .touchUpInside)
        editNameButton.isHidden = false
        bottomBar.addSubview(editNameButton)

        normalButtons = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 48))
        bottomBar.addSubview(normalButtons)

        inviteButton = UIButton(frame: editNameButton.frame)
        inviteButton.setImage(UIImage(systemName: "person.badge.plus", withConfiguration: iconConfig), for: .normal)
        inviteButton.tintColor = .brandColor
        inviteButton.addTarget(self, action: #selector(inviteTapped), for: .touchUpInside)
        normalButtons.addSubview(inviteButton)

        var origin = CGPoint(x: inviteButton.frame.origin.x + inviteButton.frame.size.width + 8, y: inviteButton.frame.origin.y)
        let reactSize = CGFloat(36)
        let buttonSpacing = CGFloat(8)
        for reaction in Room.Reaction.allCases {
            // poop emoji, only for Dean & Palley
            if reaction == .poop, userId != 1, userId != 170 {
                continue
            }

            let button = EmojiButton(frame: CGRect(origin: origin, size: CGSize(width: reactSize, height: reactSize)))
            button.setTitle(reaction.rawValue, for: .normal)
            button.addTarget(self, action: #selector(reactionTapped), for: .touchUpInside)
            origin.x += reactSize + buttonSpacing
            normalButtons.addSubview(button)
        }

        let newWidth = origin.x + reactSize + buttonSpacing

        bottomBar.frame = CGRect(
            origin: CGPoint(x: (frame.size.width / 2) - (newWidth / 2), y: bottomBar.frame.origin.y),
            size: CGSize(width: newWidth, height: bottomBar.frame.height)
        )

        offset = editNameButton.frame.size.width + editNameButton.frame.origin.x
        normalButtons.frame = CGRect(x: offset, y: 0, width: bottomBar.frame.width - offset, height: bottomBar.frame.height)

        if room.role != .admin {
            hideEditNameButton()
        }

        DispatchQueue.main.async {
            self.members.reloadData()
        }
    }

    private func hideEditNameButton() {
        UIView.animate(withDuration: 0.2) { [self] in
            editNameButton.isHidden = true
            normalButtons.frame.origin.x = 0
            bottomBar.frame.size.width = normalButtons.frame.size.width
            bottomBar.center.x = center.x
        }
    }

    private func showEditNameButton() {
        UIView.animate(withDuration: 0.2) { [self] in
            editNameButton.isHidden = false
            bottomBar.frame.size.width = normalButtons.frame.size.width + editNameButton.frame.size.width + editNameButton.frame.origin.x
            bottomBar.center.x = center.x
            normalButtons.frame.origin.x = editNameButton.frame.size.width + editNameButton.frame.origin.x
        }
    }

    @objc private func pasteLink() {
        if room.role == .audience {
            return
        }

        guard let url = UIPasteboard.general.url else {
            return
        }

        let alert = UIAlertController(
            title: NSLocalizedString("would_you_like_to_share_link", comment: ""),
            message: url.absoluteString,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .default, handler: { _ in
            self.room.share(link: url)
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .cancel, handler: nil))

        UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true)
    }

    @objc private func exitTapped() {
        if room.members.count == 0 {
            showExitAlert()
            return
        }

        exitRoom()
    }

    @objc private func muteTapped() {
        muteButton.isSelected.toggle()

        if room.isMuted {
            room.unmute()
        } else {
            room.mute()
        }

        DispatchQueue.main.async {
            self.members.reloadData()
        }
    }

    private func showExitAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("are_you_sure", comment: ""),
            message: NSLocalizedString("exit_will_close_room", comment: ""),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .destructive, handler: { _ in
            self.exitRoom()
        }))

        UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true)
    }

    private func exitRoom() {
        room.close()
        UIApplication.shared.isIdleTimerDisabled = false
        delegate?.roomDidExit()
    }

    @objc private func openBar() {
        guard let parent = superview as? DrawerView else {
            return
        }

        if parent.position == .collapsed {
            parent.setPosition(.open, animated: true)
        }
    }

    @objc private func reactionTapped(_ sender: UIButton) {
        guard let button = sender as? EmojiButton else {
            return
        }

        guard let label = button.title(for: .normal) else {
            return
        }

        guard let reaction = Room.Reaction(rawValue: label) else {
            return
        }

        room.react(with: reaction)
    }

    @objc private func editRoomNameButtonTapped() {
        let ac = UIAlertController(title: NSLocalizedString("enter_name", comment: ""), message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: NSLocalizedString("submit", comment: ""), style: .default) { [unowned ac] _ in
            let answer = ac.textFields![0]
            guard let text = answer.text else {
                return
            }

            self.room.rename(text)
        }

        ac.addAction(submitAction)

        let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel)
        ac.addAction(cancel)

        UIApplication.shared.keyWindow?.rootViewController!.present(ac, animated: true)
    }

    @objc private func inviteTapped() {
        UIApplication.shared.keyWindow?.rootViewController!.present(
            SceneFactory.createInviteFriendsListViewController(room: room),
            animated: true
        )
    }
}

extension RoomView: RoomDelegate {
    func userDidReact(user: Int, reaction: Room.Reaction) {
        DispatchQueue.main.async {
            if let cell = (self.members.visibleCells as! [RoomMemberCell]).first(where: { $0.user == user }) {
                cell.didReact(with: reaction)
            }
        }
    }

    func roomWasClosedByRemote() {
        delegate?.roomWasClosedDueToError()
    }

    func didChangeMemberMuteState(user _: Int, isMuted: Bool) {
        DispatchQueue.main.async {
            self.members.reloadData()
        }
    }

    //  @todo for efficiency these should all only update the user that was changed
    func userDidJoinRoom(user _: Int) {
        DispatchQueue.main.async {
            self.members.reloadData()
            self.playJoinedSound()
        }
    }

    func roomWasRenamed(_ name: String) {
        DispatchQueue.main.async {
            self.roomNameLabel.text = name
        }
    }

    func userDidLeaveRoom(user _: Int) {
        DispatchQueue.main.async {
            self.members.reloadData()
        }
    }

    func didChangeUserRole(user: Int, role: Room.MemberRole) {
        DispatchQueue.main.async {
            self.members.reloadData()
        }

        if user != UserDefaults.standard.integer(forKey: "id") {
            return
        }

        DispatchQueue.main.async {
            if role == .admin {
                self.showEditNameButton()
            } else {
                self.hideEditNameButton()
            }
        }
    }

    func didChangeSpeakVolume(user: Int, volume: Float) {
        DispatchQueue.main.async {
            if let cell = (self.members.visibleCells as! [RoomMemberCell]).first(where: { $0.user == user }) {
                cell.didChangeSpeakVolume(volume)
            }
        }
    }

    func didReceiveLink(from: Int, link: URL) {
        guard let user = room.members.first(where: { $0.id == from }) else {
            return
        }

        let message = NSLocalizedString("shared_link", comment: "")
        let description = NSLocalizedString("click_to_open", comment: "")

        DispatchQueue.main.async {
            let banner = GrowingNotificationBanner(
                title: String(format: message, user.displayName.firstName()),
                subtitle: String(format: description, link.absoluteString),
                style: .info
            )

            banner.onTap = {
                UIApplication.shared.open(link)
            }

            banner.show()
        }
    }

    private func playJoinedSound() {
        guard let url = Bundle.main.url(forResource: "blop", withExtension: "mp3") else {
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            DispatchQueue.global(qos: .background).async {
                self.audioPlayer.play()
            }
        } catch {
            debugPrint("\(error)")
        }
    }
}

extension RoomView: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let profileAction = UIAlertAction(title: NSLocalizedString("view_profile", comment: ""), style: .default, handler: { _ in
                DispatchQueue.main.async {
                    self.delegate?.didSelectViewProfile(id: UserDefaults.standard.integer(forKey: "id"))
                }
            })
            optionMenu.addAction(profileAction)

            let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel)
            optionMenu.addAction(cancel)

            UIApplication.shared.keyWindow?.rootViewController!.present(optionMenu, animated: true)
            return
        }

        showMemberAction(for: room.members[indexPath.item - 1])
    }

    private func showMemberAction(for member: Room.Member) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

//        @TODO: requires server fix.
//        if room.role == .owner {
//            var action: UIAlertAction
//
//            if member.role == .speaker {
//                action = UIAlertAction(title: NSLocalizedString("move_to_audience", comment: ""), style: .default, handler: { _ in
//                    self.room.remove(speaker: member.id)
//
//                })
//            } else {
//                action = UIAlertAction(title: NSLocalizedString("make_speaker", comment: ""), style: .default, handler: { _ in
//                    self.room.add(speaker: member.id)
//                })
//            }
//
//            optionMenu.addAction(action)
//        }

        let profileAction = UIAlertAction(title: NSLocalizedString("view_profile", comment: ""), style: .default, handler: { _ in
            DispatchQueue.main.async {
                self.delegate?.didSelectViewProfile(id: member.id)
            }
        })
        optionMenu.addAction(profileAction)

        if room.role == .admin {
            if member.role == .admin {
                optionMenu.addAction(
                    UIAlertAction(title: NSLocalizedString("remove_admin", comment: ""), style: .destructive, handler: { _ in
                        self.room.remove(admin: member.id)
                    })
                )
            } else {
                optionMenu.addAction(
                    UIAlertAction(title: NSLocalizedString("add_admin", comment: ""), style: .default, handler: { _ in
                        self.room.add(admin: member.id)
                    })
                )
            }

            optionMenu.addAction(
                UIAlertAction(title: NSLocalizedString("ban_from_room", comment: ""), style: .destructive, handler: { _ in
                    self.room.kick(user: member.id)
                })
            )
        }

        let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel)
        optionMenu.addAction(cancel)

        UIApplication.shared.keyWindow?.rootViewController!.present(optionMenu, animated: true)
    }
}

extension RoomView: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        // Adds the plus 1 for self.
        return room.members.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: RoomMemberCell.self, for: indexPath)
        if indexPath.item == 0 {
            // @todo this is a bit ugly
            cell.setup(
                name: UserDefaults.standard.string(forKey: "display") ?? "",
                image: UserDefaults.standard.string(forKey: "image") ?? "",
                muted: room.isMuted,
                role: room.role
            )
        } else {
            cell.setup(member: room.members[indexPath.item - 1])
        }

        return cell
    }
}
