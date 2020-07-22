//
//  NavigationViewController.swift
//  Voicely
//
//  Created by Dean Eigenmann on 22.07.20.
//

import UIKit

class NavigationViewController: UINavigationController {
    private var currentRoom: Room?

    private var roomBarView: RoomBarView?

    private let createRoomButton: CreateRoomButton

    override init(rootViewController: UIViewController) {
        createRoomButton = CreateRoomButton()

        super.init(rootViewController: rootViewController)

        navigationBar.isHidden = true

        createRoomButton.frame = CGRect(
            origin: CGPoint(x: view.frame.size.width / 2 - (70 / 2), y: view.frame.size.height - 100),
            size: createRoomButton.frame.size
        )
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        createRoomButton.addTarget(self, action: #selector(openRoom), for: .touchUpInside)
        view.addSubview(createRoomButton)

        roomBarView = RoomBarView(
            frame: CGRect(x: 0, y: view.frame.size.height - 60, width: view.frame.size.width, height: 60)
        )

        roomBarView?.isHidden = true
        roomBarView?.delegate = self
        view.addSubview(roomBarView!)
    }

    @objc func openRoom() {
        if currentRoom == nil {
            currentRoom = Room()
        }

        present(RoomViewController(room: currentRoom!), animated: true, completion: nil)

        createRoomButton.isHidden = true
        roomBarView!.isHidden = false
    }
}

extension NavigationViewController: RoomBarViewDelegate {
    func didExit() {
        roomBarView?.isHidden = true
        currentRoom = nil
        createRoomButton.isHidden = false
    }

    func didTap() {
        openRoom()
    }
}
