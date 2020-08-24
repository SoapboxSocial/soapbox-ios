//
//  RoomView.swift
//  Voicely
//
//  Created by Dean Eigenmann on 30.07.20.
//

import DrawerView
import UIKit

protocol RoomViewDelegate {
    func roomWasClosedDueToError()
    func roomDidExit()
    func didSelectViewProfile(id: Int)
}

class RoomView: UIView {
    private let reuseIdentifier = "profileCell"

    var delegate: RoomViewDelegate?

    let room: Room

    private let topBarHeight: CGFloat

    private var muteButton: UIButton!
    private var members: UICollectionView!

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

        backgroundColor = .elementBackground

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

        let label = UILabel(frame: CGRect(x: safeAreaInsets.left + 15, y: 0, width: frame.size.width / 2, height: 0))
        label.text = room.name!
        label.font = UIFont(name: "HelveticaNeue-Bold", size: label.font.pointSize)
        label.sizeToFit()
        label.center = CGPoint(x: label.center.x, y: topBar.center.y - (inset / 2))
        topBar.addSubview(label)

        let exitButton = UIButton(
            frame: CGRect(x: frame.size.width - (30 + 15 + safeAreaInsets.left), y: (frame.size.height - inset) / 2 - 15, width: 30, height: 30)
        )
        exitButton.center = CGPoint(x: exitButton.center.x, y: topBar.center.y - (inset / 2))
        exitButton.setTitle("🚪", for: .normal)
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        addSubview(exitButton)

        muteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        muteButton.setTitle("🔊", for: .normal)
        muteButton.center = CGPoint(x: exitButton.center.x - (15 + exitButton.frame.size.width), y: exitButton.center.y)
        muteButton.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)
        addSubview(muteButton)

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: 66, height: 90)

        members = UICollectionView(frame: CGRect(x: 0, y: topBar.frame.size.height, width: frame.size.width, height: frame.size.height - topBar.frame.size.height), collectionViewLayout: layout)
        members!.dataSource = self
        members!.delegate = self
        members!.register(RoomMemberCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        members!.backgroundColor = .clear
        addSubview(members)

        let flameButton = UIButton(frame: CGRect(origin: CGPoint(x: exitButton.frame.origin.x, y: frame.size.height - (exitButton.frame.size.height + 10 + safeAreaInsets.bottom)), size: exitButton.frame.size))
        flameButton.setTitle("🔥", for: .normal)
        flameButton.addTarget(self, action: #selector(flameTapped), for: .touchUpInside)
        addSubview(flameButton)

        let thumbsUpButton = UIButton(frame: CGRect(origin: CGPoint(x: flameButton.frame.origin.x - (flameButton.frame.size.width + 10), y: flameButton.frame.origin.y), size: flameButton.frame.size))
        thumbsUpButton.setTitle("👍", for: .normal)
        thumbsUpButton.addTarget(self, action: #selector(thumbsUpTapped), for: .touchUpInside)
        addSubview(thumbsUpButton)

        let heartButton = UIButton(frame: CGRect(origin: CGPoint(x: thumbsUpButton.frame.origin.x - (thumbsUpButton.frame.size.width + 10), y: thumbsUpButton.frame.origin.y), size: thumbsUpButton.frame.size))
        heartButton.setTitle("❤️", for: .normal)
        heartButton.addTarget(self, action: #selector(heartTapped), for: .touchUpInside)
        addSubview(heartButton)

        DispatchQueue.main.async {
            self.members.reloadData()
        }
    }

    @objc private func flameTapped() {
        room.react(with: .flame)
    }

    @objc private func thumbsUpTapped() {
        room.react(with: .thumbsUp)
    }

    @objc private func heartTapped() {
        room.react(with: .heart)
    }

    @objc private func exitTapped() {
        if room.members.count == 0 {
            showExitAlert()
            return
        }

        exitRoom()
    }

    @objc private func muteTapped() {
        if room.isMuted {
            muteButton!.setTitle("🔊", for: .normal)
            room.unmute()
        } else {
            muteButton!.setTitle("🔇", for: .normal)
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
        }
    }

    func userDidLeaveRoom(user _: Int) {
        DispatchQueue.main.async {
            self.members.reloadData()
        }
    }

    func didChangeUserRole(user _: Int, role _: APIClient.MemberRole) {
        DispatchQueue.main.async {
            self.members.reloadData()
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

    private func showMemberAction(for member: APIClient.Member) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if room.role == .owner {
            var action: UIAlertAction

            if member.role == .speaker {
                action = UIAlertAction(title: NSLocalizedString("move_to_audience", comment: ""), style: .default, handler: { _ in
                    self.room.remove(speaker: member.id)

                })
            } else {
                action = UIAlertAction(title: NSLocalizedString("make_speaker", comment: ""), style: .default, handler: { _ in
                    self.room.add(speaker: member.id)
                })
            }

            optionMenu.addAction(action)
        }

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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RoomMemberCell
        if indexPath.item == 0 {
            // @todo this is a bit ugly
            cell.setup(name: UserDefaults.standard.string(forKey: "display") ?? "", image: UserDefaults.standard.string(forKey: "image") ?? "", role: room.role)
        } else {
            cell.setup(member: room.members[indexPath.item - 1])
        }

        return cell
    }
}
