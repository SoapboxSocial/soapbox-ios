import AVFoundation
import DrawerView
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

        backgroundColor = .foreground

        roundCorners(corners: [.topLeft, .topRight], radius: 25.0)

        let inset = safeAreaInsets.bottom

        let topBar = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: topBarHeight + inset))
        topBar.roundCorners(corners: [.topLeft, .topRight], radius: 25.0)
        addSubview(topBar)

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(openBar))
        recognizer.numberOfTapsRequired = 1
        let recognizerView = UIView(frame: CGRect(x: 0, y: 0, width: topBar.frame.size.width, height: topBar.frame.size.height))
        recognizerView.addGestureRecognizer(recognizer)
        topBar.addSubview(recognizerView)

        let pasteLinkRecognizer = UITapGestureRecognizer(target: self, action: #selector(pasteLink))
        pasteLinkRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(pasteLinkRecognizer)

        let iconConfig = UIImage.SymbolConfiguration(weight: .medium)

        let exitButton = EmojiButton(
            frame: CGRect(x: frame.size.width - (35 + 15 + safeAreaInsets.left), y: (frame.size.height - inset) / 2 - 17.5, width: 35, height: 35)
        )
        exitButton.center = CGPoint(x: exitButton.center.x, y: topBar.center.y - (inset / 2))
        exitButton.setImage(UIImage(systemName: "xmark", withConfiguration: iconConfig), for: .normal)
        exitButton.tintColor = .secondaryBackground
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        addSubview(exitButton)

        muteButton = EmojiButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        muteButton.setImage(UIImage(systemName: "mic", withConfiguration: iconConfig), for: .normal)
        muteButton.setImage(UIImage(systemName: "mic.slash", withConfiguration: iconConfig), for: .selected)
        muteButton.tintColor = .secondaryBackground
        muteButton.center = CGPoint(x: exitButton.center.x - (15 + exitButton.frame.size.width), y: exitButton.center.y)
        muteButton.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)
        addSubview(muteButton)

        let label = UILabel(frame: CGRect(x: safeAreaInsets.left + 15, y: 0, width: muteButton.frame.origin.x - (safeAreaInsets.left + 30), height: 20))

        label.text = {
            if let name = room.name, name != "" {
                return name
            }

            return NSLocalizedString("current_room", comment: "")
        }()

        label.font = .rounded(forTextStyle: .title3, weight: .bold)
        label.center = CGPoint(x: label.center.x, y: exitButton.center.y)
        topBar.addSubview(label)

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: 66, height: 90)

        members = UICollectionView(frame: CGRect(x: 0, y: topBar.frame.size.height, width: frame.size.width, height: frame.size.height - topBar.frame.size.height), collectionViewLayout: layout)
        members!.dataSource = self
        members!.delegate = self
        members!.register(cellWithClass: RoomMemberCell.self)
        members!.backgroundColor = .clear
        addSubview(members)

        let reactSize = CGFloat(30)
        var origin = CGPoint(x: exitButton.frame.origin.x, y: frame.size.height - (reactSize + 10 + safeAreaInsets.bottom))
        for reaction in Room.Reaction.allCases {
            let button = EmojiButton(frame: CGRect(origin: origin, size: CGSize(width: reactSize, height: reactSize)))
            button.setTitle(reaction.rawValue, for: .normal)
            button.addTarget(self, action: #selector(reactionTapped), for: .touchUpInside)
            origin.x = origin.x - (button.frame.size.width + 10)
            addSubview(button)
        }

        let inviteButton = EmojiButton(
            frame: CGRect(x: safeAreaInsets.left + 15, y: frame.size.height - (reactSize + 10 + safeAreaInsets.bottom), width: 35, height: 35)
        )
        inviteButton.setImage(UIImage(systemName: "person.badge.plus", withConfiguration: iconConfig), for: .normal)
        inviteButton.tintColor = .secondaryBackground
        inviteButton.addTarget(self, action: #selector(inviteTapped), for: .touchUpInside)
        addSubview(inviteButton)

        DispatchQueue.main.async {
            self.members.reloadData()
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

    @objc private func inviteTapped() {
        // @todo this needs to be elsewhere
        let view = InviteFriendsListViewController()
        let presenter = InviteFriendsListPresenter(output: view)
        let interactor = InviteFriendsListInteractor(output: presenter, api: APIClient(), room: room)
        view.output = interactor

        UIApplication.shared.keyWindow?.rootViewController!.present(view, animated: true)
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

    func userDidLeaveRoom(user _: Int) {
        DispatchQueue.main.async {
            self.members.reloadData()
        }
    }

    func didChangeUserRole(user _: Int, role _: Room.MemberRole) {
        DispatchQueue.main.async {
            self.members.reloadData()
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
        let description = NSLocalizedString("would_you_like_to_open_link", comment: "")

        let option = UIAlertController(
            title: String(format: message, user.displayName.firstName()),
            message: String(format: description, link.absoluteString),
            preferredStyle: .alert
        )

        option.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .default, handler: { _ in
            UIApplication.shared.openURL(link)
        }))

        option.addAction(UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .cancel, handler: nil))

        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController!.present(option, animated: true)
        }
    }

    private func playJoinedSound() {
        let path = Bundle.main.path(forResource: "blop", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)

        do {
            let audioSession = AVAudioSession()
            try audioSession.setCategory(.playback, mode: .default, options: .mixWithOthers)
            try audioSession.setActive(true)

            let sound = try AVAudioPlayer(contentsOf: url)
            audioPlayer = sound
            audioPlayer.play()
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
            cell.setup(name: UserDefaults.standard.string(forKey: "display") ?? "", image: UserDefaults.standard.string(forKey: "image") ?? "", role: room.role)
        } else {
            cell.setup(member: room.members[indexPath.item - 1])
        }

        return cell
    }
}
