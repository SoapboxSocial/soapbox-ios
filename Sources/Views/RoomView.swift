import DrawerView
import LinkPresentation
import NotificationBannerSwift
import UIKit

protocol RoomViewDelegate {
    func roomWasClosedDueToError()
    func roomDidExit()
    func didSelectViewProfile(id: Int)
}

class RoomView: UIView {
    var delegate: RoomViewDelegate?

    private static let iconConfig = UIImage.SymbolConfiguration(weight: .semibold)

    private var me: RoomState.RoomMember {
        let id = Int64(UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId))
        guard let me = room.state.members.first(where: { $0.id == id }) else {
            fatalError("me not found!")
        }

        return me
    }

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

    private let content: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 20
        stack.distribution = .fill
        stack.alignment = .fill
        stack.axis = .vertical
        stack.isUserInteractionEnabled = true
        return stack
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

    private let linkView: LinkSharingView = {
        let view = LinkSharingView()
        return view
    }()

    private let room: Room

    private let userJoinFeedback: UINotificationFeedbackGenerator = {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        return generator
    }()

    private let reactFeedback: UIImpactFeedbackGenerator = {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        return generator
    }()

    private let tooltip = Tooltip.create(text: NSLocalizedString("share_room_tooltip", comment: ""))

    private var didShowTooltip = false

    enum RightButtonBar: String, Item, CaseIterable {
        case share, paste

        func icon() -> String {
            switch self {
            case .share:
                return "square.and.arrow.up"
            case .paste:
                return "link.badge.plus"
            }
        }
    }

    enum LeftButtonBar: String, Item, CaseIterable {
        case settings, invite, miniApp

        func icon() -> String {
            switch self {
            case .settings:
                return "gearshape"
            case .invite:
                return "person.badge.plus"
            case .miniApp:
                return "gamecontroller"
            }
        }
    }

    private var leftButtonBar = ButtonBar<LeftButtonBar>()
    private var rightButtonBar = ButtonBar<RightButtonBar>()

    init(room: Room) {
        self.room = room

        super.init(frame: CGRect.zero)

        backgroundColor = .roomBackground

        room.delegate = self

        roomWasRenamed(room.state.name)

        translatesAutoresizingMaskIntoConstraints = false

        let buttonBar = UIView()
        buttonBar.backgroundColor = .roomButtonBar
        buttonBar.translatesAutoresizingMaskIntoConstraints = false
        buttonBar.layer.cornerRadius = 25
        addSubview(buttonBar)

        addSubview(foreground)

        foreground.addSubview(content)

        content.addArrangedSubview(linkView)

        linkView.isHidden = true
        linkView.delegate = self

        NSLayoutConstraint.activate([
            linkView.heightAnchor.constraint(lessThanOrEqualTo: content.heightAnchor, multiplier: 0.66),
        ])

        content.addArrangedSubview(members)

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
            content.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height - (68 + 20 + 32 + 40 + 57 + 76)).isActive = true
        } else {
            content.heightAnchor.constraint(equalToConstant: UICollectionViewFlowLayout.heightForBubbleLayout(rows: 4, width: UIScreen.main.bounds.width)).isActive = true
        }

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: exitButton.bottomAnchor, constant: 20),
            content.leftAnchor.constraint(equalTo: foreground.leftAnchor),
            content.rightAnchor.constraint(equalTo: foreground.rightAnchor),
            foreground.bottomAnchor.constraint(equalTo: content.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            members.leftAnchor.constraint(equalTo: foreground.leftAnchor),
            members.rightAnchor.constraint(equalTo: foreground.rightAnchor),
        ])

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: topAnchor),
            topBar.leftAnchor.constraint(equalTo: leftAnchor),
            topBar.rightAnchor.constraint(equalTo: rightAnchor),
            topBar.bottomAnchor.constraint(equalTo: content.topAnchor),
        ])

        bottomMuteButton.backgroundColor = .roomBackground
        addSubview(bottomMuteButton)

        leftButtonBar.delegate = self
        buttonBar.addSubview(leftButtonBar)

        NSLayoutConstraint.activate([
            leftButtonBar.centerYAnchor.constraint(equalTo: bottomMuteButton.centerYAnchor),
            leftButtonBar.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            leftButtonBar.heightAnchor.constraint(equalToConstant: 32),
        ])

        rightButtonBar.delegate = self
        buttonBar.addSubview(rightButtonBar)

        NSLayoutConstraint.activate([
            rightButtonBar.centerYAnchor.constraint(equalTo: bottomMuteButton.centerYAnchor),
            rightButtonBar.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            rightButtonBar.heightAnchor.constraint(equalToConstant: 32),
        ])

        NSLayoutConstraint.activate([
            bottomMuteButton.topAnchor.constraint(equalTo: foreground.bottomAnchor, constant: 10),
            bottomMuteButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            bottomMuteButton.heightAnchor.constraint(equalToConstant: 56),
            bottomMuteButton.widthAnchor.constraint(equalToConstant: 56),
        ])

        NSLayoutConstraint.activate([
            buttonBar.topAnchor.constraint(equalTo: foreground.bottomAnchor, constant: -50),
            buttonBar.leftAnchor.constraint(equalTo: leftAnchor),
            buttonBar.rightAnchor.constraint(equalTo: rightAnchor),
            buttonBar.bottomAnchor.constraint(equalTo: bottomMuteButton.bottomAnchor, constant: 10),
        ])

        let userId = UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId)
        let emojis = EmojiBar(emojis: Room.Reaction.allCases.filter { !($0 == .poop && userId != 1 && userId != 170) })
        emojis.delegate = self
        addSubview(emojis)

        NSLayoutConstraint.activate([
            emojis.topAnchor.constraint(equalTo: bottomMuteButton.bottomAnchor, constant: 20),
            emojis.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])

        let isMuted = me.muted
        muteButton.isSelected = isMuted
        bottomMuteButton.isSelected = isMuted

        linkView.adminRoleChanged(isAdmin: me.role == .admin)

        if me.role != .admin {
            leftButtonBar.hide(button: .settings)

            if room.state.visibility == .private {
                leftButtonBar.hide(button: .invite)
            }
        }

        visibilityUpdated(visibility: room.state.visibility)

        if room.state.link != "" {
            guard let url = URL(string: room.state.link) else {
                return
            }

            linkView.pinned(link: url)
        }
    }

    func showMuteButton() {
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.5,
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

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func hideViews() -> [UIView] {
        return [content]
    }

    static func height() -> CGFloat {
        return UICollectionViewFlowLayout.heightForBubbleLayout(rows: 4, width: UIScreen.main.bounds.width) + 76 + 104
    }

    @objc private func exitTapped() {
        if room.state.members.count == 1 {
            showExitAlert()
            return
        }

        exitRoom()
    }

    @objc private func muteTapped() {
        muteButton.isSelected.toggle()
        bottomMuteButton.isSelected.toggle()

        if me.muted {
            room.unmute()
        } else {
            room.mute()
        }

        DispatchQueue.main.async {
            self.members.reloadData()
        }
    }

    private func showExitAlert() {
        let alert = UIAlertController.confirmation(
            onAccepted: {
                self.exitRoom()
            },
            message: NSLocalizedString("exit_will_close_room", comment: ""),
            confirm: NSLocalizedString("leave_room", comment: "")
        )

        window!.rootViewController!.present(alert, animated: true)
    }

    private func exitRoom() {
        room.close()
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
}

extension RoomView: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let id = UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId)
        if room.state.members[indexPath.item].id == Int64(id) {
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let profileAction = UIAlertAction(title: NSLocalizedString("view_profile", comment: ""), style: .default, handler: { _ in
                DispatchQueue.main.async {
                    self.delegate?.didSelectViewProfile(id: id)
                }
            })
            optionMenu.addAction(profileAction)

            let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel)
            optionMenu.addAction(cancel)

            window!.rootViewController!.present(optionMenu, animated: true)
            return
        }

        showMemberAction(for: room.state.members[indexPath.item])
    }

    private func showMemberAction(for member: RoomState.RoomMember) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let profileAction = UIAlertAction(title: NSLocalizedString("view_profile", comment: ""), style: .default, handler: { _ in
            DispatchQueue.main.async {
                self.delegate?.didSelectViewProfile(id: Int(member.id))
            }
        })
        optionMenu.addAction(profileAction)

        if me.role == .admin {
            optionMenu.addAction(UIAlertAction(title: NSLocalizedString("mute_user", comment: ""), style: .default, handler: { _ in
                self.room.mute(user: member.id)
            }))

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
                    let message = NSLocalizedString("user_will_no_longer_be_able_to_join_room", comment: "")

                    let alert = UIAlertController.confirmation(
                        onAccepted: {
                            self.room.kick(user: member.id)
                        },
                        message: String(format: message, member.displayName.firstName())
                    )

                    DispatchQueue.main.async {
                        self.window!.rootViewController!.present(alert, animated: true)
                    }
                })
            )
        }

        let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel)
        optionMenu.addAction(cancel)

        window!.rootViewController!.present(optionMenu, animated: true)
    }
}

extension RoomView: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return room.state.members.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: RoomMemberCell.self, for: indexPath)

        cell.setup(member: room.state.members[indexPath.item])

        return cell
    }
}

extension RoomView: RoomDelegate {
    func usersSpeaking(users: [Int]) {
        DispatchQueue.main.async {
            guard let cells = self.members.visibleCells as? [RoomMemberCell] else {
                return
            }

            for cell in cells {
                cell.isSpeaking = users.contains(Int(cell.user ?? 0))
            }
        }
    }

    func userWasInvitedToBeAdmin(by: Int64) {
        let title = NSLocalizedString("invited_to_be_admin_by", comment: "")

        guard let member = room.state.members.first(where: { $0.id == by }) else {
            return
        }

        let alert = UIAlertController(
            title: String(format: title, member.displayName.firstName()),
            message: NSLocalizedString("would_you_like_to_accept", comment: ""),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .default, handler: { _ in
            self.room.acceptInvite()
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .cancel))

        DispatchQueue.main.async {
            self.window!.rootViewController!.present(alert, animated: true)
        }
    }

    func wasMutedByAdmin() {
        DispatchQueue.main.async {
            self.muteButton.isSelected = true
            self.bottomMuteButton.isSelected = true
            self.members.reloadItems(at: [IndexPath(item: 0, section: 0)])
        }
    }

    func userDidReact(user: Int64, reaction: Room.Reaction) {
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

    func didChangeMemberMuteState(user _: Int64, isMuted: Bool) {
        DispatchQueue.main.async {
            self.members.reloadData()
        }
    }

    //  @todo for efficiency these should all only update the user that was changed
    func userDidJoinRoom(user _: Int64) {
        DispatchQueue.main.async {
            self.members.reloadData()
            self.userJoinFeedback.notificationOccurred(.success)
            self.userJoinFeedback.prepare()
        }
    }

    func roomWasRenamed(_ name: String) {
        DispatchQueue.main.async {
            if name == "" {
                self.name.text = NSLocalizedString("current_room", comment: "")
                return
            }

            self.name.text = name
        }
    }

    func userDidLeaveRoom(user _: Int64) {
        DispatchQueue.main.async {
            self.members.reloadData()
        }
    }

    func didChangeUserRole(user: Int64, role: RoomState.RoomMember.Role) {
        DispatchQueue.main.async {
            self.members.reloadData()
        }

        if user != Int64(UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId)) {
            return
        }

        DispatchQueue.main.async {
            if role == .admin {
                self.linkView.adminRoleChanged(isAdmin: true)
                self.leftButtonBar.show(button: .settings)
                self.leftButtonBar.show(button: .invite)
            } else {
                self.linkView.adminRoleChanged(isAdmin: false)
                self.leftButtonBar.hide(button: .settings)

                if self.room.state.visibility == .private {
                    self.leftButtonBar.hide(button: .invite)
                }
            }
        }
    }

    func didReceiveLink(from: Int64, link: URL) {
        var name = "you"
        if from != 0 {
            guard let user = room.state.members.first(where: { $0.id == from }) else {
                return
            }

            name = user.displayName
        }

        DispatchQueue.main.async {
            self.linkView.displayLink(link: link, name: name)
        }
    }

    func userDidRecordScreen(_ user: Int64) {
        guard let user = room.state.members.first(where: { $0.id == user }) else {
            return
        }

        let message = NSLocalizedString("user_started_recording_screen", comment: "")

        DispatchQueue.main.async {
            let banner = GrowingNotificationBanner(
                title: String(format: message, user.displayName.firstName()),
                style: .info
            )

            banner.show()
        }
    }

    func visibilityUpdated(visibility: Visibility) {
        DispatchQueue.main.async {
            switch visibility {
            case .private:
                self.lock.isHidden = false
                self.rightButtonBar.hide(button: .share)

                if self.me.role != .admin {
                    self.leftButtonBar.hide(button: .invite)
                }

            case .public:
                self.lock.isHidden = true
                self.rightButtonBar.show(button: .share)
                self.leftButtonBar.show(button: .invite)
            default:
                return
            }
        }
    }

    func linkWasPinned(link: URL) {
        DispatchQueue.main.async {
            self.rightButtonBar.hide(button: .paste)
        }

        linkView.pinned(link: link)
    }

    func pinnedLinkWasRemoved() {
        DispatchQueue.main.async {
            self.rightButtonBar.show(button: .paste)
        }

        linkView.removePinnedLink()
    }
}

extension RoomView: EmojiBarDelegate {
    func did(react reaction: Room.Reaction) {
        room.react(with: reaction)
        reactFeedback.impactOccurred()
        reactFeedback.prepare()
    }
}

extension RoomView: LinkSharingViewDelegate {
    func didPin(link: URL) {
        room.pin(link: link)
        rightButtonBar.hide(button: .paste)
    }

    func didUnpin() {
        room.unpin()
        rightButtonBar.show(button: .paste)
    }
}

extension RoomView: ButtonBarDelegate {
    func didTap(button sender: UIButton) {
        switch sender {
        case let button as ButtonBar<RightButtonBar>.Button:
            switch button.value {
            case .paste:
                return pasteTapped()
            case .share:
                return shareTapped()
            default:
                return
            }
        case let button as ButtonBar<LeftButtonBar>.Button:
            switch button.value {
            case .invite:
                return inviteTapped()
            case .settings:
                return settingsTapped()
            default:
                return
            }
        default:
            return
        }
    }

    private func settingsTapped() {
        RoomSettingsSheet.show(forRoom: room, on: window!.rootViewController!)
    }

    private func inviteTapped() {
        window!.rootViewController!.present(
            SceneFactory.createInviteFriendsListViewController(room: room),
            animated: true
        )
    }

    private func shareTapped() {
        tooltip.dismiss()

        if room.state.id == "" {
            return
        }

        let data = LPLinkMetadata()
        data.originalURL = URL(string: "https://soapbox.social/room/" + room.state.id)!

        let format = NSLocalizedString("share_room", comment: "")
        data.title = String(format: format, name.text!)

        let ac = UIActivityViewController(activityItems: [MetadataItemSource(metadata: data)], applicationActivities: nil)
        ac.excludedActivityTypes = [.markupAsPDF, .openInIBooks, .addToReadingList, .assignToContact]
        window!.rootViewController!.present(ac, animated: true)
    }

    private func pasteTapped() {
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

        window!.rootViewController!.present(alert, animated: true)
    }
}
