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

    private var audioPlayer: AVAudioPlayer!

    private static let iconConfig = UIImage.SymbolConfiguration(weight: .semibold)

    private let muteButton: EmojiButton = {
        let button = EmojiButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "mic", withConfiguration: iconConfig), for: .normal)
        button.setImage(UIImage(systemName: "mic.slash", withConfiguration: iconConfig), for: .selected)
        button.tintColor = .brandColor
        button.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)
        return button
    }()

    private let exitButton: EmojiButton = {
        let button = EmojiButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark", withConfiguration: iconConfig), for: .normal)
        button.tintColor = .systemRed
        button.backgroundColor = .exitButtonBackground
        button.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        return button
    }()

    private let editNameButton: EmojiButton = {
        let button = EmojiButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "gearshape", withConfiguration: iconConfig), for: .normal)
        button.tintColor = .brandColor
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(editRoomNameButtonTapped), for: .touchUpInside)
        return button
    }()

    private let inviteUsersButton: EmojiButton = {
        let button = EmojiButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "person.badge.plus", withConfiguration: iconConfig), for: .normal)
        button.tintColor = .brandColor
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(inviteTapped), for: .touchUpInside)
        return button
    }()

    private let bottomMuteButton: EmojiButton = {
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)

        let button = EmojiButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "mic", withConfiguration: iconConfig), for: .normal)
        button.setImage(UIImage(systemName: "mic.slash", withConfiguration: iconConfig), for: .selected)
        button.tintColor = .brandColor
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)
        return button
    }()

    private let pasteButton: EmojiButton = {
        let button = EmojiButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "doc.on.clipboard", withConfiguration: iconConfig), for: .normal)
        button.tintColor = .brandColor
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(pasteLink), for: .touchUpInside)
        return button
    }()

    private let name: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title2, weight: .bold)
        return label
    }()

    private let foreground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .roomForeground
        view.layer.cornerRadius = 25
        return view
    }()

    private let members: UICollectionView = {
        let layout = UICollectionViewFlowLayout.basicUserBubbleLayout(itemsPerRow: 4, width: UIScreen.main.bounds.width)

        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(cellWithClass: RoomMemberCell.self)
        collection.backgroundColor = .clear
        collection.layer.masksToBounds = true

        return collection
    }()

    private let lock: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let lock = UIImageView(image: UIImage(systemName: "lock", withConfiguration: RoomView.iconConfig))
        lock.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        lock.tintColor = .label
        lock.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lock)

        return view
    }()

    private let room: Room

    init(room: Room) {
        self.room = room

        super.init(frame: CGRect.zero)

        backgroundColor = .roomBackground

        room.delegate = self

        name.text = {
            if let name = room.name, name != "" {
                return name
            }

            return NSLocalizedString("current_room", comment: "")

        }()

        translatesAutoresizingMaskIntoConstraints = false

        let buttonBar = UIView()
        buttonBar.backgroundColor = .roomButtonBar
        buttonBar.translatesAutoresizingMaskIntoConstraints = false
        buttonBar.layer.cornerRadius = 25
        addSubview(buttonBar)

        addSubview(foreground)
        foreground.addSubview(members)

        let handle = UIView()
        handle.translatesAutoresizingMaskIntoConstraints = false
        handle.backgroundColor = .handle
        handle.layer.cornerRadius = 2.5
        addSubview(handle)

        let topBar = UIView()
        topBar.translatesAutoresizingMaskIntoConstraints = false
        foreground.addSubview(topBar)

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(stack)

        stack.addArrangedSubview(lock)
        stack.addArrangedSubview(name)

        NSLayoutConstraint.activate([
            lock.topAnchor.constraint(equalTo: name.topAnchor),
            lock.heightAnchor.constraint(equalToConstant: 20),
            lock.widthAnchor.constraint(equalToConstant: 20),
        ])

        if room.visibility == .public {
            lock.isHidden = true
        }

        let topButtonStack = UIStackView()
        topButtonStack.axis = .horizontal
        topButtonStack.spacing = 20
        topButtonStack.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(topButtonStack)

        topButtonStack.addArrangedSubview(muteButton)
        topButtonStack.addArrangedSubview(exitButton)

        topBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openBar)))

        members.dataSource = self
        members.delegate = self

        NSLayoutConstraint.activate([
            handle.centerXAnchor.constraint(equalTo: centerXAnchor),
            handle.heightAnchor.constraint(equalToConstant: 5),
            handle.widthAnchor.constraint(equalToConstant: 36),
            handle.topAnchor.constraint(equalTo: topAnchor, constant: 5),
        ])

        NSLayoutConstraint.activate([
            foreground.leftAnchor.constraint(equalTo: leftAnchor),
            foreground.topAnchor.constraint(equalTo: topAnchor),
            foreground.rightAnchor.constraint(equalTo: rightAnchor),
        ])

        NSLayoutConstraint.activate([
            muteButton.topAnchor.constraint(equalTo: foreground.topAnchor, constant: 20),
            muteButton.heightAnchor.constraint(equalToConstant: 32),
            muteButton.widthAnchor.constraint(equalToConstant: 32),
        ])

        muteButton.isHidden = true

        NSLayoutConstraint.activate([
            exitButton.topAnchor.constraint(equalTo: foreground.topAnchor, constant: 20),
            exitButton.rightAnchor.constraint(equalTo: foreground.rightAnchor, constant: -20),
            exitButton.heightAnchor.constraint(equalToConstant: 32),
            exitButton.widthAnchor.constraint(equalToConstant: 32),
        ])

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            stack.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            stack.rightAnchor.constraint(equalTo: topButtonStack.leftAnchor, constant: -10),
            stack.heightAnchor.constraint(equalToConstant: 32),
        ])

        NSLayoutConstraint.activate([
            topButtonStack.rightAnchor.constraint(equalTo: rightAnchor),
            topButtonStack.heightAnchor.constraint(equalToConstant: 32),
        ])

        if UIScreen.main.bounds.height <= 736 {
            members.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height - (68 + 20 + 32 + 40 + 57 + 76)).isActive = true
        } else {
            members.heightAnchor.constraint(equalToConstant: UICollectionViewFlowLayout.heightForBubbleLayout(rows: 4, width: UIScreen.main.bounds.width)).isActive = true
        }

        NSLayoutConstraint.activate([
            members.topAnchor.constraint(equalTo: exitButton.bottomAnchor, constant: 40),
            members.leftAnchor.constraint(equalTo: foreground.leftAnchor),
            members.rightAnchor.constraint(equalTo: foreground.rightAnchor),
            foreground.bottomAnchor.constraint(equalTo: members.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: topAnchor),
            topBar.leftAnchor.constraint(equalTo: leftAnchor),
            topBar.rightAnchor.constraint(equalTo: rightAnchor),
            topBar.bottomAnchor.constraint(equalTo: members.topAnchor),
        ])

        let buttonStack = UIStackView()
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.spacing = 10
        buttonBar.addSubview(buttonStack)

        addSubview(pasteButton)
        addSubview(bottomMuteButton)

        buttonStack.addArrangedSubview(editNameButton)
        buttonStack.addArrangedSubview(inviteUsersButton)

        NSLayoutConstraint.activate([
            buttonStack.centerYAnchor.constraint(equalTo: bottomMuteButton.centerYAnchor),
            buttonStack.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
        ])

        NSLayoutConstraint.activate([
            editNameButton.heightAnchor.constraint(equalToConstant: 32),
            editNameButton.widthAnchor.constraint(equalToConstant: 32),
        ])

        NSLayoutConstraint.activate([
            inviteUsersButton.heightAnchor.constraint(equalToConstant: 32),
            inviteUsersButton.widthAnchor.constraint(equalToConstant: 32),
        ])

        bottomMuteButton.backgroundColor = .roomBackground

        NSLayoutConstraint.activate([
            bottomMuteButton.topAnchor.constraint(equalTo: foreground.bottomAnchor, constant: 10),
            bottomMuteButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            bottomMuteButton.heightAnchor.constraint(equalToConstant: 56),
            bottomMuteButton.widthAnchor.constraint(equalToConstant: 56),
        ])

        NSLayoutConstraint.activate([
            pasteButton.centerYAnchor.constraint(equalTo: bottomMuteButton.centerYAnchor),
            pasteButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            pasteButton.heightAnchor.constraint(equalToConstant: 32),
            pasteButton.widthAnchor.constraint(equalToConstant: 32),
        ])

        NSLayoutConstraint.activate([
            buttonBar.topAnchor.constraint(equalTo: foreground.bottomAnchor, constant: -50),
            buttonBar.leftAnchor.constraint(equalTo: leftAnchor),
            buttonBar.rightAnchor.constraint(equalTo: rightAnchor),
            buttonBar.bottomAnchor.constraint(equalTo: bottomMuteButton.bottomAnchor, constant: 10),
        ])

        let emojis = UIView()
        emojis.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emojis)

        let userId = UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId)

        var left = emojis.leftAnchor
        var leftOffset = CGFloat(0)

        for reaction in Room.Reaction.allCases {
            // poop emoji, only for Dean & Palley
            if reaction == .poop, userId != 1, userId != 170 {
                continue
            }

            let button = EmojiButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(reaction.rawValue, for: .normal)
            button.addTarget(self, action: #selector(reactionTapped), for: .touchUpInside)
            button.backgroundColor = .clear
            emojis.addSubview(button)

            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 32),
                button.widthAnchor.constraint(equalToConstant: 32),
                button.leftAnchor.constraint(equalTo: left, constant: leftOffset),
            ])

            left = button.rightAnchor
            leftOffset = 20
        }

        NSLayoutConstraint.activate([
            emojis.topAnchor.constraint(equalTo: bottomMuteButton.bottomAnchor, constant: 20),
            emojis.rightAnchor.constraint(equalTo: left),
            emojis.heightAnchor.constraint(equalToConstant: 32),
            emojis.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])

        muteButton.isSelected = room.isMuted
        bottomMuteButton.isSelected = room.isMuted

        room.mute()

        if room.role != .admin {
            editNameButton.isHidden = true

            if room.visibility == .private {
                inviteUsersButton.isHidden = true
            }
        }
    }

    func showMuteButton() {
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: .curveEaseOut,
            animations: { [self] in
                muteButton.isHidden = false
                muteButton.alpha = 1
            }
        )
    }

    func hideMuteButton() {
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: .curveEaseOut,
            animations: { [self] in
                muteButton.isHidden = true
                muteButton.alpha = 0
            }
        )
    }

    private func hideEditNameButton() {
        UIView.animate(withDuration: 0.2) { [self] in
            editNameButton.isHidden = true
        }
    }

    private func showEditNameButton() {
        UIView.animate(withDuration: 0.2) { [self] in
            editNameButton.isHidden = false
        }
    }

    private func hideInviteUserButton() {
        UIView.animate(withDuration: 0.2) { [self] in
            inviteUsersButton.isHidden = true
        }
    }

    private func showInviteUserButton() {
        UIView.animate(withDuration: 0.2) { [self] in
            inviteUsersButton.isHidden = false
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func hideViews() -> [UIView] {
        return [members]
    }

    static func height() -> CGFloat {
        return UICollectionViewFlowLayout.heightForBubbleLayout(rows: 4, width: UIScreen.main.bounds.width) + 76 + 104
    }

    @objc private func pasteLink() {
        if room.role == .audience {
            return
        }

        var url: URL?
        if let pasted = UIPasteboard.general.url {
            url = pasted
        }

        if let str = UIPasteboard.general.string, let pasted = URL(string: str) {
            url = pasted
        }

        if url == nil || !UIApplication.shared.canOpenURL(url!) {
            let banner = NotificationBanner(title: NSLocalizedString("nothing_to_share", comment: ""))
            banner.show()
            return
        }

        let alert = UIAlertController(
            title: NSLocalizedString("would_you_like_to_share_link", comment: ""),
            message: url!.absoluteString,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .default, handler: { _ in
            self.room.share(link: url!)
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
        bottomMuteButton.isSelected.toggle()

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
        let alert = UIAlertController(title: NSLocalizedString("enter_name", comment: ""), message: nil, preferredStyle: .alert)
        alert.addTextField()

        let submitAction = UIAlertAction(title: NSLocalizedString("submit", comment: ""), style: .default) { [unowned alert] _ in
            let answer = alert.textFields![0]
            guard let text = answer.text else {
                return
            }

            self.room.rename(text)
        }

        alert.addAction(submitAction)

        let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel)
        alert.addAction(cancel)

        UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true)
    }

    @objc private func inviteTapped() {
        UIApplication.shared.keyWindow?.rootViewController!.present(
            SceneFactory.createInviteFriendsListViewController(room: room),
            animated: true
        )
    }
}

extension RoomView: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let profileAction = UIAlertAction(title: NSLocalizedString("view_profile", comment: ""), style: .default, handler: { _ in
                DispatchQueue.main.async {
                    self.delegate?.didSelectViewProfile(id: UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId))
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
                name: UserDefaults.standard.string(forKey: UserDefaultsKeys.userDisplay) ?? "",
                image: UserDefaults.standard.string(forKey: UserDefaultsKeys.userImage) ?? "",
                muted: room.isMuted,
                role: room.role
            )
        } else {
            cell.setup(member: room.members[indexPath.item - 1])
        }

        return cell
    }
}

extension RoomView: RoomDelegate {
    func userDidReact(user: Int, reaction: Room.Reaction) {
        DispatchQueue.main.async {
            guard let cells = self.members.visibleCells as? [RoomMemberCell] else {
                return
            }

            if let cell = cells.first(where: { $0.user == user }) {
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
            self.name.text = name
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

        if user != UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId) {
            return
        }

        DispatchQueue.main.async {
            if role == .admin {
                self.showEditNameButton()
                self.showInviteUserButton()
            } else {
                self.hideEditNameButton()

                if self.room.visibility == .private {
                    self.hideInviteUserButton()
                }
            }
        }
    }

    func didChangeSpeakVolume(user: Int, volume: Float) {
        DispatchQueue.main.async {
            guard let cells = self.members.visibleCells as? [RoomMemberCell] else {
                return
            }

            if let cell = cells.first(where: { $0.user == user }) {
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
