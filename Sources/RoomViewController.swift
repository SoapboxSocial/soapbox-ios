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

    var memberList = [String]()

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
        members!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
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
}

extension RoomViewController: UICollectionViewDelegate {}

extension RoomViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        // Adds the plus 1 for self.
        return self.memberList.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if indexPath.item == 0 {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
            label.text = "You"
            label.textAlignment = .center
            label.textColor = .elementBackground
            cell.contentView.addSubview(label)
        }

        cell.contentView.layer.cornerRadius = 30
        cell.contentView.clipsToBounds = true
        cell.contentView.backgroundColor = .highlight
        return cell
    }
}
