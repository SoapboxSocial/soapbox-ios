import FloatingPanel
import UIKit

protocol RoomViewDelegate {
    func roomWasClosedDueToError()
    func roomDidExit()
    func didSelectViewProfile(id: Int)
}

class RoomController: FloatingPanelController {
    private class Layout: FloatingPanelLayout {
        let position: FloatingPanelPosition = .bottom
        let initialState: FloatingPanelState = .hidden

        var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
            return [
                .full: FloatingPanelLayoutAnchor(absoluteInset: 68, edge: .top, referenceGuide: .superview),
                .tip: FloatingPanelLayoutAnchor(absoluteInset: 68.0 + safeBottomArea(), edge: .bottom, referenceGuide: .superview),
            ]
        }

        private func safeBottomArea() -> CGFloat {
            guard let window = UIApplication.shared.keyWindow else {
                return 0.0
            }

            return window.safeAreaInsets.bottom
        }
    }

    private let vc: RoomViewController

    var roomDelegate: RoomViewDelegate? {
        didSet {
            vc.delegate = roomDelegate
        }
    }

    // @TODO PROBABLY REFACTOR
    private class RoomViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, RoomDelegate {
        var delegate: RoomViewDelegate?
        var room: Room

        private var members: UICollectionView!

        init(room: Room) {
            self.room = room
            super.init(nibName: nil, bundle: nil)
            room.delegate = self
        }

        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidLoad() {
            super.viewDidLoad()

            let title = UILabel()
            title.font = .rounded(forTextStyle: .title2, weight: .bold)
            title.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(title)

            title.text = {
                if let name = room.name, name != "" {
                    return name
                }

                return NSLocalizedString("current_room", comment: "")
            }()

            let iconConfig = UIImage.SymbolConfiguration(weight: .medium)

            let pasteLinkRecognizer = UITapGestureRecognizer(target: self, action: #selector(pasteLink))
            pasteLinkRecognizer.numberOfTapsRequired = 2
            view.addGestureRecognizer(pasteLinkRecognizer)

            let exitButton = EmojiButton(frame: CGRect.zero)
            exitButton.setImage(UIImage(systemName: "xmark", withConfiguration: iconConfig), for: .normal)
            exitButton.tintColor = .secondaryBackground
            exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
            exitButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(exitButton)

            let muteButton = EmojiButton(frame: CGRect.zero)
            muteButton.setImage(UIImage(systemName: "mic", withConfiguration: iconConfig), for: .normal)
            muteButton.setImage(UIImage(systemName: "mic.slash", withConfiguration: iconConfig), for: .selected)
            muteButton.tintColor = .secondaryBackground
            muteButton.translatesAutoresizingMaskIntoConstraints = false
            muteButton.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)
            view.addSubview(muteButton)

            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10)
            layout.itemSize = CGSize(width: 66, height: 90)

            members = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
            members!.dataSource = self
            members!.delegate = self
            members!.register(cellWithClass: RoomMemberCell.self)
            members!.backgroundColor = .clear
            members.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(members)

            DispatchQueue.main.async {
                self.members.reloadData()
            }

            NSLayoutConstraint.activate([
                title.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
                title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            ])

            NSLayoutConstraint.activate([
                exitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
                exitButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
                exitButton.heightAnchor.constraint(equalToConstant: 36),
                exitButton.widthAnchor.constraint(equalToConstant: 36),
            ])

            NSLayoutConstraint.activate([
                muteButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
                muteButton.rightAnchor.constraint(equalTo: exitButton.leftAnchor, constant: -20),
                muteButton.heightAnchor.constraint(equalToConstant: 36),
                muteButton.widthAnchor.constraint(equalToConstant: 36),
            ])

            NSLayoutConstraint.activate([
                members.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 24),
                members.leftAnchor.constraint(equalTo: view.leftAnchor),
                members.rightAnchor.constraint(equalTo: view.rightAnchor),
                members.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        }

        @objc private func exitTapped() {
            func shutdown() {
                room.close()
                UIApplication.shared.isIdleTimerDisabled = false
                delegate?.roomDidExit()
            }

            func showExitAlert() {
                let alert = UIAlertController(
                    title: NSLocalizedString("are_you_sure", comment: ""),
                    message: NSLocalizedString("exit_will_close_room", comment: ""),
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .destructive, handler: { _ in
                    shutdown()
                }))

                UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true)
            }

            if room.members.count == 0 {
                showExitAlert()
                return
            }

            shutdown()
        }

        @objc private func muteTapped(sender: UIButton) {
            sender.isSelected.toggle()

            if room.isMuted {
                room.unmute()
            } else {
                room.mute()
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
    }

    init(room: Room) {
        vc = RoomViewController(room: room)
        super.init(delegate: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        layout = Layout()

        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 30.0
        appearance.backgroundColor = .foreground

        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: 16)
        shadow.radius = 16
        shadow.spread = 8
        appearance.shadows = [shadow]

        surfaceView.appearance = appearance
        surfaceView.grabberHandle.isHidden = false
        panGestureRecognizer.isEnabled = true
        panGestureRecognizer.cancelsTouchesInView = false

        set(contentViewController: vc)
    }
}
