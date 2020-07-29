//
//  RoomViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 22.07.20.
//

import UIKit

protocol RoomViewDelegate {
    func roomViewDidTapExit()
    func roomViewDidTapMute()
    func roomViewWasClosed()
}

class RoomViewController: UIViewController {
    private let reuseIdentifier = "profileCell"

    private let room: Room

    var delegate: RoomViewDelegate?

    var members: UICollectionView!

    var memberList = [APIClient.Member]()

    init(room: Room) {
        self.room = room
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        view.backgroundColor = .elementBackground

        let inset = view.safeAreaInsets.bottom

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: 60, height: 60)

        members = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height - (inset + 45 + 30)), collectionViewLayout: layout)
        members!.dataSource = self
        members!.delegate = self
        members!.register(RoomMemberCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        members!.backgroundColor = .clear
        view.addSubview(members)

        updateData()

        // @todo animations
        let exitButton = UIButton(
            frame: CGRect(x: view.frame.size.width - (30 + 15), y: (view.frame.size.height - inset) - 45, width: 30, height: 30)
        )
        exitButton.setTitle("👉", for: .normal)
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        view.addSubview(exitButton)

        let muteButton = UIButton(frame: CGRect(x: view.frame.size.width - (60 + 30), y: (view.frame.size.height - inset) - 45, width: 30, height: 30))

        muteButton.setTitle("🔊", for: .normal)
        setMuteButtonTitle(muteButton)
        muteButton.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)
        view.addSubview(muteButton)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        delegate?.roomViewWasClosed()
    }

    func updateData() {
        DispatchQueue.main.async {
            self.memberList = self.room.members
            self.members.reloadData()
        }
    }

    @objc private func exitTapped() {
        delegate?.roomViewDidTapExit()
    }

    private func setMuteButtonTitle(_ button: UIButton) {
        if room.isMuted {
            button.setTitle("🔇", for: .normal)
        } else {
            button.setTitle("🔊", for: .normal)
        }
    }

    @objc private func muteTapped(sender: UIButton) {
        delegate?.roomViewDidTapMute()
        setMuteButtonTitle(sender)
    }

    fileprivate func showRoleAction(for member: APIClient.Member) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if member.role == .speaker {
            let action = UIAlertAction(title: NSLocalizedString("move_to_audience", comment: ""), style: .default, handler: { _ in
                self.room.remove(speaker: member.id)

                DispatchQueue.main.async {
                    self.updateData()
                }

            })
            optionMenu.addAction(action)
        } else {
            let action = UIAlertAction(title: NSLocalizedString("make_speaker", comment: ""), style: .default, handler: { _ in
                self.room.add(speaker: member.id)

                DispatchQueue.main.async {
                    self.updateData()
                }

            })
            optionMenu.addAction(action)
        }

        let action = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel)
        optionMenu.addAction(action)

        self.present(optionMenu, animated: true, completion: nil)
    }
}

extension RoomViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            return
        }

        if self.room.role != .owner {
            return
        }

        showRoleAction(for: memberList[indexPath.item - 1])
    }
}

extension RoomViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        // Adds the plus 1 for self.
        return self.memberList.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RoomMemberCell
        if indexPath.item == 0 {
            cell.setup(isSelf: true, role: self.room.role)
        } else {
            cell.setup(isSelf: false, role: self.memberList[indexPath.item - 1].role)
        }

        return cell
    }
}
