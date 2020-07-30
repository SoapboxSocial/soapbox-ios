//
//  RoomView.swift
//  Voicely
//
//  Created by Dean Eigenmann on 30.07.20.
//

import UIKit

protocol NewRoomViewDelegate {
    func roomDidExit()
}

class RoomView: UIView {
    private let reuseIdentifier = "profileCell"

    var delegate: NewRoomViewDelegate?

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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // @todo this is ugly but for a lack of a better place to put set up right now we put it here.
        if muteButton != nil {
            return
        }
        
        layer.cornerRadius = 10.0

        let inset = safeAreaInsets.bottom

        let topBar = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: topBarHeight + inset))
        topBar.roundCorners(corners: [.topLeft, .topRight], radius: 9.0)
        addSubview(topBar)
        
        let label = UILabel(frame: CGRect(x: safeAreaInsets.left + 15, y: 0, width: frame.size.width, height: 0))
        label.text = "Yay room"
        label.sizeToFit()
        label.center = CGPoint(x: label.center.x, y: topBar.center.y - (inset / 2))
        topBar.addSubview(label)
        
        let exitButton = UIButton(
            frame: CGRect(x: frame.size.width - (30 + 15 + safeAreaInsets.left), y: (frame.size.height - inset) / 2 - 15, width: 30, height: 30)
        )
        
        exitButton.center = CGPoint(x: exitButton.center.x, y: topBar.center.y - (inset / 2))

        exitButton.setTitle("👉", for: .normal)
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        addSubview(exitButton)
        
        muteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        muteButton!.setTitle("🔊", for: .normal)
        muteButton.center = CGPoint(x: exitButton.center.x - (15 + exitButton.frame.size.width), y: exitButton.center.y)
        muteButton!.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)
        addSubview(muteButton!)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: 60, height: 60)

        members = UICollectionView(frame: CGRect(x: 0, y: topBar.frame.size.height, width: frame.size.width, height: frame.size.height - topBar.frame.size.height), collectionViewLayout: layout)
        members!.dataSource = self
        members!.delegate = self
        members!.register(RoomMemberCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        members!.backgroundColor = .clear
        addSubview(members)

        DispatchQueue.main.async {
            self.members.reloadData()
        }
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
}

extension RoomView: RoomDelegate {
    //  @todo for efficiency these should all only update the user that was changed
    func userDidJoinRoom(user: String) {
        DispatchQueue.main.async {
            self.members.reloadData()
        }
    }
    
    func userDidLeaveRoom(user: String) {
        DispatchQueue.main.async {
            self.members.reloadData()
        }
    }
    
    func didChangeUserRole(user: String, role: APIClient.MemberRole) {
        DispatchQueue.main.async {
            self.members.reloadData()
        }
    }
}

extension RoomView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            return
        }

        if self.room.role != .owner {
            return
        }

        showRoleAction(for: self.room.members[indexPath.item - 1])
    }
    
    private func showRoleAction(for member: APIClient.Member) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

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

        let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel)
        optionMenu.addAction(cancel)

        UIApplication.shared.keyWindow?.rootViewController!.present(optionMenu, animated: true)
    }
}

extension RoomView: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        // Adds the plus 1 for self.
        return self.room.members.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RoomMemberCell
        if indexPath.item == 0 {
            cell.setup(isSelf: true, role: self.room.role)
        } else {
            cell.setup(isSelf: false, role: self.room.members[indexPath.item - 1].role)
        }

        return cell
    }
}
