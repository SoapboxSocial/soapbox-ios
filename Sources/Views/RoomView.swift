import DrawerView
import LinkPresentation
import UIKit

protocol RoomViewDelegate: AnyObject {
    func roomWasClosedDueToError()
    func roomDidExit()
    func didSelectViewProfile(id: Int)
}

class RoomView: UIView {
    weak var delegate: RoomViewDelegate?

    private static let iconConfig = UIImage.SymbolConfiguration(weight: .semibold)

    private var me: Soapbox_V1_RoomState.RoomMember {
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
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .semibold)

        let button = EmojiButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "mic", withConfiguration: iconConfig), for: .normal)
        button.setImage(UIImage(systemName: "mic.slash", withConfiguration: iconConfig), for: .selected)
        button.tintColor = .brandColor
        button.backgroundColor = .background
        button.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)
        return button
    }()

    private let name: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .rounded(forTextStyle: .title2, weight: .bold)
        return label
    }()

    private let members: UICollectionView = {
        let layout = UICollectionViewFlowLayout.basicUserBubbleLayout(itemsPerRow: 4, width: UIScreen.main.bounds.width)

        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.register(cellWithClass: RoomMemberCell.self)
        collection.backgroundColor = .clear
        collection.layer.masksToBounds = true
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false

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

    private let reactFeedback: UIImpactFeedbackGenerator = {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        return generator
    }()

    private var roomWasShared = false

    enum RightButtonBar: String, Item, CaseIterable {
        case minis, paste

        func icon() -> String {
            switch self {
            case .minis:
                return "gamecontroller"
            case .paste:
                return "link.badge.plus"
            }
        }
    }

    enum LeftButtonBar: String, Item, CaseIterable {
        case settings, invite

        func icon() -> String {
            switch self {
            case .settings:
                return "gearshape"
            case .invite:
                return "person.badge.plus"
            }
        }
    }

    private var leftButtonBar = ButtonBar<LeftButtonBar>()
    private var rightButtonBar = ButtonBar<RightButtonBar>()

    private var miniView: MiniView?

    init(room: Room) {
        self.room = room

        super.init(frame: CGRect.zero)

        room.delegate = self
        roomWasRenamed(room.state.name)

        backgroundColor = .background

        content.addArrangedSubview(linkView)

        linkView.isHidden = true
        linkView.delegate = self

        NSLayoutConstraint.activate([
            linkView.heightAnchor.constraint(lessThanOrEqualTo: content.heightAnchor, multiplier: 0.66),
        ])

        content.addArrangedSubview(members)
        members.delegate = self
        members.dataSource = self

        NSLayoutConstraint.activate([
            members.leftAnchor.constraint(equalTo: content.leftAnchor),
            members.rightAnchor.constraint(equalTo: content.rightAnchor),
        ])

        NSLayoutConstraint.activate([
            linkView.leftAnchor.constraint(equalTo: content.leftAnchor),
            linkView.rightAnchor.constraint(equalTo: content.rightAnchor),
        ])

        let userId = UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId)
        let emojis = EmojiBar(emojis: Room.Reaction.allCases.filter { !($0 == .poop && userId != 1 && userId != 170) })
        emojis.delegate = self
        addSubview(emojis)

        NSLayoutConstraint.activate([
            emojis.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            emojis.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])

        let body = UIView()
        body.backgroundColor = .foreground
        body.translatesAutoresizingMaskIntoConstraints = false
        body.layer.cornerRadius = 30
        body.clipsToBounds = true
        addSubview(body)

        NSLayoutConstraint.activate([
            body.leftAnchor.constraint(equalTo: leftAnchor),
            body.rightAnchor.constraint(equalTo: rightAnchor),
            body.topAnchor.constraint(equalTo: topAnchor),
            body.bottomAnchor.constraint(equalTo: emojis.topAnchor, constant: -10),
        ])

        let handle = UIView()
        handle.translatesAutoresizingMaskIntoConstraints = false
        handle.backgroundColor = .quaternaryLabel
        handle.layer.cornerRadius = 2.5
        body.addSubview(handle)

        NSLayoutConstraint.activate([
            handle.centerXAnchor.constraint(equalTo: centerXAnchor),
            handle.heightAnchor.constraint(equalToConstant: 5),
            handle.widthAnchor.constraint(equalToConstant: 36),
            handle.topAnchor.constraint(equalTo: body.topAnchor, constant: 5),
        ])

        body.addSubview(content)

        NSLayoutConstraint.activate([
            content.leftAnchor.constraint(equalTo: body.leftAnchor, constant: 20),
            content.rightAnchor.constraint(equalTo: body.rightAnchor, constant: -20),
            content.bottomAnchor.constraint(equalTo: body.bottomAnchor),
        ])

        let gradient = GradientView(color: .foreground)
        gradient.translatesAutoresizingMaskIntoConstraints = false
        gradient.clipsToBounds = true
        body.addSubview(gradient)

        body.addSubview(bottomMuteButton)

        NSLayoutConstraint.activate([
            gradient.topAnchor.constraint(equalTo: bottomMuteButton.topAnchor, constant: -20),
            gradient.leftAnchor.constraint(equalTo: body.leftAnchor),
            gradient.rightAnchor.constraint(equalTo: body.rightAnchor),
            gradient.bottomAnchor.constraint(equalTo: body.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            bottomMuteButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            bottomMuteButton.bottomAnchor.constraint(equalTo: body.bottomAnchor, constant: -20),
            bottomMuteButton.widthAnchor.constraint(equalToConstant: 64),
            bottomMuteButton.heightAnchor.constraint(equalToConstant: 64),
        ])

        let header = createHeader()
        body.addSubview(header)

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: header.bottomAnchor),
            header.topAnchor.constraint(equalTo: body.topAnchor),
            header.leftAnchor.constraint(equalTo: body.leftAnchor),
            header.rightAnchor.constraint(equalTo: body.rightAnchor),
        ])

        leftButtonBar.delegate = self
        body.addSubview(leftButtonBar)

        NSLayoutConstraint.activate([
            leftButtonBar.bottomAnchor.constraint(equalTo: bottomMuteButton.bottomAnchor),
            leftButtonBar.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            leftButtonBar.heightAnchor.constraint(equalToConstant: 40),
        ])

        rightButtonBar.delegate = self
        body.addSubview(rightButtonBar)

        NSLayoutConstraint.activate([
            rightButtonBar.bottomAnchor.constraint(equalTo: bottomMuteButton.bottomAnchor),
            rightButtonBar.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            rightButtonBar.heightAnchor.constraint(equalToConstant: 40),
        ])

        let isMuted = me.muted
        muteButton.isSelected = isMuted
        bottomMuteButton.isSelected = isMuted

        linkView.adminRoleChanged(isAdmin: me.role == .admin)

        if me.role != .admin {
            leftButtonBar.hide(button: .settings, animated: false)

            if room.state.visibility == .private {
                leftButtonBar.hide(button: .invite, animated: false)
            }
        }

        visibilityUpdated(visibility: room.state.visibility)

        if room.state.hasMini, room.state.mini.id != 0 {
            rightButtonBar.hide(button: .minis, animated: false)
            rightButtonBar.hide(button: .paste, animated: false)
            open(mini: room.state.mini, isAppOpener: false)
        }

        if room.state.link != "" {
            guard let url = URL(string: room.state.link) else {
                return
            }

            linkView.pinned(link: url)
        }

        pulsateSocial()
    }

    private func createHeader() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let touchView = UIView()
        touchView.translatesAutoresizingMaskIntoConstraints = false
        touchView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openBar)))
        view.addSubview(touchView)

        NSLayoutConstraint.activate([
            touchView.leftAnchor.constraint(equalTo: view.leftAnchor),
            touchView.rightAnchor.constraint(equalTo: view.rightAnchor),
            touchView.topAnchor.constraint(equalTo: view.topAnchor),
            touchView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 20
        buttonStack.alignment = .center
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            buttonStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 32),
        ])

        buttonStack.addArrangedSubview(muteButton)
        buttonStack.addArrangedSubview(exitButton)

        NSLayoutConstraint.activate([
            muteButton.heightAnchor.constraint(equalToConstant: 32),
            muteButton.widthAnchor.constraint(equalToConstant: 32),
        ])

        muteButton.isHidden = true

        NSLayoutConstraint.activate([
            exitButton.heightAnchor.constraint(equalToConstant: 32),
            exitButton.widthAnchor.constraint(equalToConstant: 32),
        ])

        let titleStack = UIStackView()
        titleStack.axis = .horizontal
        titleStack.spacing = 10
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.distribution = .fill
        titleStack.alignment = .center
        view.addSubview(titleStack)

        titleStack.addArrangedSubview(lock)
        titleStack.addArrangedSubview(name)

        NSLayoutConstraint.activate([
            titleStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            titleStack.rightAnchor.constraint(equalTo: buttonStack.rightAnchor, constant: -20),
            titleStack.heightAnchor.constraint(equalToConstant: 32),
        ])

        NSLayoutConstraint.activate([
            lock.heightAnchor.constraint(equalToConstant: 20),
            lock.widthAnchor.constraint(equalToConstant: 20),
        ])

        view.bottomAnchor.constraint(equalTo: titleStack.bottomAnchor, constant: 20).isActive = true

        return view
    }

    func showMuteButton() {
        VisibilityPopAnimation.show(muteButton)
    }

    func hideMuteButton() {
        VisibilityPopAnimation.hide(muteButton)
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

        DispatchQueue.main.async {
            if self.me.muted {
                self.room.unmute()
            } else {
                self.room.mute()
            }

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
        if let mini = miniView {
            mini.shutdown()
            mini.removeFromSuperview()
            miniView = nil
        }

        delegate?.roomDidExit()
        miniView?.close()
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
            let sheet = ActionSheet()
            sheet.add(action: ActionSheet.Action(title: NSLocalizedString("view_profile", comment: ""), style: .default, handler: { _ in
                DispatchQueue.main.async {
                    self.delegate?.didSelectViewProfile(id: id)
                }
            }))

            sheet.add(action: ActionSheet.Action(title: NSLocalizedString("cancel", comment: ""), style: .cancel))
            window!.rootViewController!.present(sheet, animated: true)
            return
        }

        showMemberAction(for: room.state.members[indexPath.item])
    }

    private func showMemberAction(for member: Soapbox_V1_RoomState.RoomMember) {
        let sheet = ActionSheet()
        sheet.add(action: ActionSheet.Action(title: NSLocalizedString("view_profile", comment: ""), style: .default, handler: { _ in
            DispatchQueue.main.async {
                self.delegate?.didSelectViewProfile(id: Int(member.id))
            }
        }))

        if me.role == .admin {
            sheet.add(action: ActionSheet.Action(title: NSLocalizedString("mute_user", comment: ""), style: .default, handler: { _ in
                self.room.mute(user: member.id)
            }))

            if member.role == .admin {
                sheet.add(action: ActionSheet.Action(title: NSLocalizedString("remove_admin", comment: ""), style: .destructive, handler: { _ in
                    self.room.remove(admin: member.id)
                }))
            } else {
                sheet.add(action: ActionSheet.Action(title: NSLocalizedString("add_admin", comment: ""), style: .default, handler: { _ in
                    self.room.add(admin: member.id)
                }))
            }

            sheet.add(action: ActionSheet.Action(title: NSLocalizedString("ban_from_room", comment: ""), style: .destructive, handler: { _ in
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
            }))
        }

        sheet.add(action: ActionSheet.Action(title: NSLocalizedString("cancel", comment: ""), style: .cancel))
        window!.rootViewController!.present(sheet, animated: true)
    }
}

extension RoomView: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return room.state.members.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: RoomMemberCell.self, for: indexPath)

        // This is a hack, there were occasions where it tried to add someone to the room UI.
        if indexPath.item < room.state.members.count {
            cell.setup(member: room.state.members[indexPath.item])
        } else {
            cell.blank()
        }

        return cell
    }
}

extension RoomView: RoomDelegate {
    func requested(mini: Soapbox_V1_RoomState.Mini, from: Int64) {
        guard let member = room.state.members.first(where: { $0.id == from }) else {
            return
        }

        let title = String(format: NSLocalizedString("user_wants_to_start_mini", comment: ""), member.displayName.firstName(), mini.name)

        LocalNotificationService.send(body: title)

        let alert = UIAlertController(
            title: title,
            message: NSLocalizedString("would_you_like_to_accept", comment: ""),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .default, handler: { _ in
            self.room.open(mini: mini)
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .cancel))

        DispatchQueue.main.async {
            self.window!.rootViewController!.present(alert, animated: true)
        }
    }

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
        guard let member = room.state.members.first(where: { $0.id == by }) else {
            return
        }

        let title = String(format: NSLocalizedString("invited_to_be_admin_by", comment: ""), member.displayName.firstName())

        LocalNotificationService.send(body: title)

        let alert = UIAlertController(
            title: title,
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
            self.members.reloadData()
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
        }

        Sounds.blop()
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

    func didChangeUserRole(user: Int64, role: Soapbox_V1_RoomState.RoomMember.Role) {
        DispatchQueue.main.async {
            self.members.reloadData()
        }

        if user != Int64(UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId)) {
            return
        }

        DispatchQueue.main.async {
            if role == .admin {
                self.linkView.adminRoleChanged(isAdmin: true)
                self.leftButtonBar.show(button: .settings, animated: true)
                self.leftButtonBar.show(button: .invite, animated: true)

                if let mini = self.miniView {
                    mini.adminRoleChanged(isAdmin: true)
                }
            } else {
                self.linkView.adminRoleChanged(isAdmin: false)
                self.leftButtonBar.hide(button: .settings, animated: true)

                if self.room.state.visibility == .private {
                    self.leftButtonBar.hide(button: .invite, animated: true)
                }

                if let mini = self.miniView {
                    mini.adminRoleChanged(isAdmin: false)
                }
            }
        }
    }

    func didReceiveLink(from: Int64, link: URL) {
        if miniView != nil {
            linkView.isHidden = true
            return
        }

        var name = "you"
        if from != 0 {
            guard let user = room.state.members.first(where: { $0.id == from }) else {
                return
            }

            name = user.displayName

            LocalNotificationService.send(body: String(format: NSLocalizedString("user_shared_a_link", comment: ""), name))
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
            let banner = NotificationBanner(
                title: String(format: message, user.displayName.firstName()),
                style: .info,
                type: .normal
            )

            banner.show()
        }
    }

    func visibilityUpdated(visibility: Soapbox_V1_Visibility) {
        DispatchQueue.main.async {
            switch visibility {
            case .private:
                self.lock.isHidden = false

                if self.me.role != .admin {
                    self.leftButtonBar.hide(button: .invite, animated: true)
                }

            case .public:
                self.lock.isHidden = true
                self.leftButtonBar.show(button: .invite, animated: true)
            default:
                return
            }
        }
    }

    func linkWasPinned(link: URL) {
        if miniView != nil {
            linkView.isHidden = true
            return
        }

        DispatchQueue.main.async {
            self.rightButtonBar.hide(button: .paste, animated: true)
            self.rightButtonBar.hide(button: .minis, animated: true)
        }

        linkView.pinned(link: link)
    }

    func pinnedLinkWasRemoved() {
        DispatchQueue.main.async {
            self.rightButtonBar.show(button: .paste, animated: true)
            self.rightButtonBar.show(button: .minis, animated: true)
        }

        linkView.removePinnedLink()
    }

    func opened(mini: Soapbox_V1_RoomState.Mini, from: Int64) {
        if from != 0 {
            guard let user = room.state.members.first(where: { $0.id == from }) else {
                return
            }

            LocalNotificationService.send(
                body: String(format: NSLocalizedString("user_opened_mini", comment: ""), user.displayName, mini.name)
            )
        }

        DispatchQueue.main.async {
            self.rightButtonBar.hide(button: .minis, animated: true)
            self.rightButtonBar.hide(button: .paste, animated: true)
            self.open(mini: mini, isAppOpener: from == 0)
        }
    }

    func closedMini(source: Bool) {
        DispatchQueue.main.async {
            if self.miniView == nil {
                return
            }

            self.miniView?.isHidden = true

            let mini = self.miniView
            self.miniView?.close {
                if !source {
                    return
                }

                mini?.removeFromSuperview()
            }

            self.rightButtonBar.show(button: .minis, animated: true)
            self.rightButtonBar.show(button: .paste, animated: true)

            if !source {
                mini?.removeFromSuperview()
            }

            self.miniView = nil
        }
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
        rightButtonBar.hide(button: .paste, animated: true)
        rightButtonBar.hide(button: .minis, animated: true)
    }

    func didUnpin() {
        room.unpin()
        rightButtonBar.show(button: .paste, animated: true)
        rightButtonBar.show(button: .minis, animated: true)
    }
}

extension RoomView: ButtonBarDelegate {
    func didTap(button sender: UIButton) {
        switch sender {
        case let button as ButtonBar<RightButtonBar>.Button:
            switch button.value {
            case .paste:
                return pasteTapped()
            case .minis:
                return minisTapped()
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

    private func minisTapped() {
        let directory = MinisDirectoryView()
        directory.onSelected = { app in
            directory.dismiss(animated: true, completion: {
                if self.me.role == .admin {
                    return self.room.open(mini: app)
                }

                let banner = NotificationBanner(
                    title: String(format: NSLocalizedString("you_requested_to_start_mini", comment: ""), app.name),
                    subtitle: nil,
                    style: .info,
                    type: .floating
                )

                banner.show()

                self.room.request(mini: app.id)
            })
        }
        directory.manager.drawer.openHeightBehavior = .fixed(height: frame.size.height / 2)
        window!.rootViewController!.present(directory, animated: true)
    }

    private func settingsTapped() {
        RoomSettingsSheet.show(forRoom: room, on: window!.rootViewController!)
    }

    private func inviteTapped() {
        roomWasShared = true

        window!.rootViewController!.present(
            ShareSheetDrawerViewController(room: room),
            animated: true
        )
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

    private func open(mini: Soapbox_V1_RoomState.Mini, isAppOpener opener: Bool) {
        if miniView != nil {
            return
        }

        miniView = MiniView(app: mini, room: room, appOpener: opener)
        miniView?.delegate = self

        content.insertArrangedSubview(miniView!, at: 0)

        NSLayoutConstraint.activate([
            miniView!.leftAnchor.constraint(equalTo: content.leftAnchor),
            miniView!.rightAnchor.constraint(equalTo: content.rightAnchor),
        ])

        switch mini.size {
        case .large:
            miniView!.bottomAnchor.constraint(equalTo: bottomMuteButton.topAnchor, constant: -10).isActive = true
        case .small:
            miniView!.heightAnchor.constraint(equalTo: content.heightAnchor, multiplier: 0.33).isActive = true
        default:
            miniView!.heightAnchor.constraint(equalTo: content.heightAnchor, multiplier: 0.66).isActive = true
        }
    }
}

extension RoomView: MiniViewDelegate {
    func didTapCloseMiniView(_: MiniView) {
        room.closeMini()
    }
}

extension RoomView: DrawerViewPanDelegate {
    func shouldHandle(pan: UIPanGestureRecognizer) -> Bool {
        guard let view = miniView else {
            return true
        }

        let translation = pan.location(in: self)

        let converted = view.convert(translation, from: self)

        return !view.frame.contains(converted)
    }
}

extension RoomView {
    func pulsateSocial() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
            guard let self = self else {
                return
            }

            if self.roomWasShared {
                return
            }

            if self.room.state.members.count > 3 || self.room.state.visibility == .private {
                return
            }

            guard let button = self.leftButtonBar.buttons[.invite] else { return }
            button.layer.cornerRadius = button.frame.size.width / 2

            for platform in SocialDeeplink.Platform.allCases {
                if !SocialDeeplink.canOpen(platform: platform) {
                    continue
                }

                return PulsatingButtonAnimation.animate(
                    button,
                    icon: UIImage(named: platform.rawValue)!,
                    color: platform.color
                )
            }
        }
    }
}
